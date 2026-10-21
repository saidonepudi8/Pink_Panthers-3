from app.features.auth.models import User

# Function to check if new user or existing
def get_user_by_email(email):
	return User.query.filter_by(email=email).first()
