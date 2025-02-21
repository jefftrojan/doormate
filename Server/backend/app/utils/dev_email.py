class DevEmailService:
    @staticmethod
    def store_email(to_email: str, subject: str, content: str):
        with open("dev_emails.txt", "a") as f:
            f.write(f"\n{'='*50}\n")
            f.write(f"To: {to_email}\n")
            f.write(f"Subject: {subject}\n")
            f.write(f"Content:\n{content}\n")