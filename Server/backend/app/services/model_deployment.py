import tensorflow as tf
from datetime import datetime
import os
import shutil

class ModelDeployment:
    def __init__(self):
        self.models_dir = "models"
        self.active_model_path = f"{self.models_dir}/active_model.h5"
        
    async def deploy_model(self, version: str):
        try:
            model_path = f"{self.models_dir}/roommate_matching_model_{version}.h5"
            if not os.path.exists(model_path):
                raise ValueError("Model version not found")
                
            # Backup current model
            if os.path.exists(self.active_model_path):
                backup_path = f"{self.models_dir}/backup_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.h5"
                shutil.copy2(self.active_model_path, backup_path)
            
            # Deploy new model
            shutil.copy2(model_path, self.active_model_path)
            return True
        except Exception as e:
            print(f"Model deployment failed: {str(e)}")
            return False
            
    async def rollback_deployment(self):
        try:
            # Find latest backup
            backups = [f for f in os.listdir(self.models_dir) if f.startswith("backup_")]
            if not backups:
                raise ValueError("No backup found")
                
            latest_backup = sorted(backups)[-1]
            backup_path = f"{self.models_dir}/{latest_backup}"
            
            # Restore backup
            shutil.copy2(backup_path, self.active_model_path)
            return True
        except Exception as e:
            print(f"Rollback failed: {str(e)}")
            return False