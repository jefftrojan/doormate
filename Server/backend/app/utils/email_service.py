import resend
from typing import Optional
import os
from dotenv import load_dotenv

load_dotenv()

class EmailService:
    def __init__(self):
        self.api_key = os.getenv('RESEND_API_KEY')
        resend.api_key = self.api_key
        # Use Resend's default testing domain
        self.from_email = "DoorMate <onboarding@resend.dev>"

    async def send_verification_email(self, to_email: str, otp: str) -> bool:
        try:
            params = {
                "from": self.from_email,
                "to": to_email,
                "subject": "Verify Your DoorMate Account",
                "html": f"""
                    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                        <h2>Welcome to DoorMate!</h2>
                        <p>Please use the following code to verify your email address:</p>
                        <div style="background-color: #f4f4f4; padding: 10px; text-align: center; font-size: 24px; letter-spacing: 5px; margin: 20px 0;">
                            <strong>{otp}</strong>
                        </div>
                        <p>This code will expire in 10 minutes.</p>
                        <p>If you didn't request this verification, please ignore this email.</p>
                    </div>
                """
            }
            
            response = resend.Emails.send(params)
            success = bool(response.get('id'))
            if not success:
                print(f"Email send failed: {response}")
            return success
        except Exception as e:
            print(f"Error sending verification email: {str(e)}")
            return False

    async def send_otp_email(self, to_email: str, otp: str, is_registration: bool = True) -> bool:
        subject = "Welcome to DoorMate - Verify Your Email" if is_registration else "DoorMate Login Code"
        content = f"""
        <h2>Welcome to DoorMate!</h2>
        <p>Your verification code is: <strong>{otp}</strong></p>
        <p>This code is valid for 10 minutes.</p>
        <p>If you didn't request this code, please ignore this email.</p>
        """
        
        try:
            params = {
                "from": self.from_email,
                "to": to_email,
                "subject": subject,
                "html": content
            }
            
            response = resend.Emails.send(params)
            return bool(response.get('id'))
        except Exception as e:
            print(f"Error sending email: {str(e)}")
            return False