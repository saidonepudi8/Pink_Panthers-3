import os

class Config:
	SECRET_KEY = os.environ.get("SECRET_KEY", "dev-only")
	JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY", SECRET_KEY)
	SQLALCHEMY_DATABASE_URI = os.environ.get(
		"DATABASE_URL", "sqlite:///pest_terminator.db"
	)
	SQLALCHEMY_TRACK_MODIFICATIONS = False
	CORS_ORIGINS = os.environ.get("CORS_ORIGINS", "*")
