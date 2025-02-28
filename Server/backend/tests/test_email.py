import asyncio
from app.utils.email_service import EmailService

async def test_mailgun():
    email_service = EmailService()
    success, message = await email_service.test_connection()
    print(f"Connection test: {message}")
    
    if success:
        # Use the verified email address
        test_email = "j.dauda@alustudent.com"  # Your verified email
        result = await email_service.send_otp_email(
            test_email,
            "123456",
            is_registration=True
        )
        print(f"Email send test: {'Successful' if result else 'Failed'}")

if __name__ == "__main__":
    asyncio.run(test_mailgun())