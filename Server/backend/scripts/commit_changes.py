import subprocess
from pathlib import Path

def run_git_command(command):
    try:
        result = subprocess.run(command, shell=True, check=True, capture_output=True, text=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error executing git command: {e}")
        return None

def commit_changes():
    changes = {
        "app/services/auth.py": {
            "type": "feat",
            "scope": "auth",
            "message": "implement comprehensive OTP authentication system",
            "details": [
                "Add password hashing for user registration",
                "Implement OTP generation and verification",
                "Add OTP regeneration functionality",
                "Add login with password verification",
                "Improve error handling and logging"
            ]
        },
        "app/utils/email_service.py": {
            "type": "feat",
            "scope": "email",
            "message": "add email service for OTP delivery",
            "details": [
                "Implement development email service",
                "Add OTP email templates",
                "Add email sending functionality"
            ]
        },
        "app/models/user.py": {
            "type": "enhancement",
            "scope": "models",
            "message": "improve user model handling",
            "details": [
                "Add ObjectId serialization",
                "Add user response models",
                "Add OTP verification models"
            ]
        },
        "app/routes/auth.py": {
            "type": "feat",
            "scope": "routes",
            "message": "implement authentication endpoints",
            "details": [
                "Add user registration endpoint",
                "Add OTP verification endpoint",
                "Add login endpoint",
                "Add OTP regeneration endpoint"
            ]
        },
        "requirements.txt": {
            "type": "enhancement",
            "scope": "deps",
            "message": "update project dependencies",
            "details": [
                "Add email validation dependencies",
                "Add MongoDB async driver",
                "Add password hashing libraries"
            ]
        }
    }

    for file, commit_info in changes.items():
        file_path = Path(file)
        if file_path.exists():
            # Add file to git
            run_git_command(f"git add {file}")
            
            # Create commit message
            commit_msg = f"{commit_info['type']}({commit_info['scope']}): {commit_info['message']}\n\n"
            commit_msg += "\n".join(f"- {detail}" for detail in commit_info['details'])
            
            # Commit changes
            run_git_command(f'git commit -m "{commit_msg}"')
            print(f"Committed changes for {file}")
        else:
            print(f"File {file} not found, skipping...")

if __name__ == "__main__":
    commit_changes()