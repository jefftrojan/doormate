import resend
from typing import Optional
import os
from dotenv import load_dotenv
import logging

load_dotenv()

class EmailService:
    def __init__(self):
        self.api_key = os.getenv('RESEND_API_KEY')
        resend.api_key = self.api_key
        # Use the verified domain instead of Resend's default testing domain
        self.from_email = "DoorMate <verify@doormate.xyz>"
        # The verified email for testing (only needed in test mode, but we're using a verified domain now)
        self.verified_test_email = "j.dauda@alustudent.com"
        # Check if we're in development mode
        self.is_dev_mode = os.getenv('ENVIRONMENT', 'development') == 'development'

    async def send_verification_email(self, to_email: str, otp: str) -> bool:
        try:
            # Create email content
            html_content = f"""
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
            
            # Since we're using a verified domain, we can send to any email
            # But still keep the mock option for development mode if needed
            if self.is_dev_mode and os.getenv('USE_MOCK_EMAIL', 'false').lower() == 'true':
                # In dev mode with mock email enabled, use mock
                logging.info(f"MOCK EMAIL to {to_email}: Verification OTP: {otp}")
                print(f"MOCK EMAIL SENT to {to_email}: Verification OTP: {otp}")
                return True
            
            # Otherwise try to send real email with verified domain
            params = {
                "from": self.from_email,
                "to": to_email,
                "subject": "Verify Your DoorMate Account",
                "html": html_content
            }
            
            response = resend.Emails.send(params)
            success = bool(response.get('id'))
            if success:
                print(f"Email successfully sent to {to_email}")
            else:
                print(f"Email send failed: {response}")
            return success
        except Exception as e:
            print(f"Error sending verification email: {str(e)}")
            # If we're in dev mode, still return success so the app flow can continue
            if self.is_dev_mode:
                print(f"MOCK EMAIL SENT to {to_email}: Verification OTP: {otp}")
                return True
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
            # Since we're using a verified domain, we can send to any email
            # But still keep the mock option for development mode if needed
            if self.is_dev_mode and os.getenv('USE_MOCK_EMAIL', 'false').lower() == 'true':
                # In dev mode with mock email enabled, use mock
                logging.info(f"MOCK EMAIL to {to_email}: OTP: {otp}")
                print(f"MOCK EMAIL SENT to {to_email}: OTP: {otp}")
                return True
                
            # Otherwise try to send real email with verified domain
            params = {
                "from": self.from_email,
                "to": to_email,
                "subject": subject,
                "html": content
            }
            
            response = resend.Emails.send(params)
            success = bool(response.get('id'))
            if success:
                print(f"Email successfully sent to {to_email}")
            else:
                print(f"Email send failed: {response}")
            return success
        except Exception as e:
            print(f"Error sending email: {str(e)}")
            # If we're in dev mode, still return success so the app flow can continue
            if self.is_dev_mode:
                print(f"MOCK EMAIL SENT to {to_email}: OTP: {otp}")
                return True
            return False