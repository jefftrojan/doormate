from fastapi_mail import FastMail, MessageSchema, ConnectionConfig
import os
from dotenv import load_dotenv
from pydantic import EmailStr

load_dotenv()

conf = ConnectionConfig(
    MAIL_USERNAME=os.getenv("MAIL_USERNAME"),
    MAIL_PASSWORD=os.getenv("MAIL_PASSWORD"),
    MAIL_FROM=os.getenv("MAIL_FROM"),
    MAIL_PORT=int(os.getenv("MAIL_PORT", "587")),
    MAIL_SERVER=os.getenv("MAIL_SERVER"),
    MAIL_STARTTLS=True,
    MAIL_SSL_TLS=False,
    USE_CREDENTIALS=True,
    VALIDATE_CERTS=True
)

fastmail = FastMail(conf)

async def send_verification_email(email: EmailStr, otp: str):
    try:
        message = MessageSchema(
            subject="Verify Your DoorMate Account",
            recipients=[email],
            body=f"""
            <html>
                <body>
                    <h1>Welcome to DoorMate!</h1>
                    <p>Your verification code is: <strong>{otp}</strong></p>
                    <p>This code will expire in 10 minutes.</p>
                </body>
            </html>
            """,
            subtype="html"
        )
        
        await fastmail.send_message(message)
        return True
    except Exception as e:
        print(f"Error sending email: {str(e)}")
        return False