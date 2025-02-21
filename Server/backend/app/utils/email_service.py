import requests
import aiohttp
from typing import Optional
import os
from dotenv import load_dotenv

load_dotenv()

class EmailService:
    def __init__(self):
        # For development, use DevEmailService if Mailgun credentials are not set
        self.use_dev_mode = not (os.getenv('MAILGUN_API_KEY') and os.getenv('MAILGUN_DOMAIN'))
        if not self.use_dev_mode:
            self.domain = os.getenv('MAILGUN_DOMAIN')
            self.api_key = os.getenv('MAILGUN_API_KEY')
            self.base_url = f"https://api.eu.mailgun.net/v3/{self.domain}"
            self.from_email = f"DoorMate <noreply@{self.domain}>"

    async def send_otp_email(self, to_email: str, otp: str, is_registration: bool = True) -> bool:
        if self.use_dev_mode:
            # Print to console in development mode
            print("\n=== Development Email ===")
            print(f"To: {to_email}")
            print(f"Subject: {'Registration' if is_registration else 'Login'} OTP")
            print(f"OTP: {otp}")
            print("=====================\n")
            return True

        # Real email sending logic for production
        subject = "Welcome to DoorMate - Verify Your Email" if is_registration else "DoorMate Login Code"
        content = f"""
        <h2>Welcome to DoorMate!</h2>
        <p>Your verification code is: <strong>{otp}</strong></p>
        <p>This code is valid for 10 minutes.</p>
        <p>If you didn't request this code, please ignore this email.</p>
        """
        
        try:
            async with aiohttp.ClientSession() as session:
                auth = aiohttp.BasicAuth('api', self.api_key)
                async with session.post(
                    f"{self.base_url}/messages",
                    auth=auth,
                    data={
                        "from": self.from_email,
                        "to": to_email,
                        "subject": subject,
                        "html": content
                    }
                ) as response:
                    return response.status == 200
        except Exception as e:
            print(f"Error sending email: {str(e)}")
            return False