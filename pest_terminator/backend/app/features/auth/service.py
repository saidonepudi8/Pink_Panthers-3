from flask_jwt_extended import create_access_token, create_refresh_token
from werkzeug.security import check_password_hash

from app.errors import ApiError
from app.features.auth.repository import get_user_by_email

_INVALID_CREDENTIALS = "Incorrect email or password."

# Uses helper function to check if user exists in DB then if pwd is correct. If both yes, returns tokens.
def login(credentials):
	user = get_user_by_email(credentials["email"])
	if user is None or not check_password_hash(
		user.password_hash, credentials["password"]
	):
		raise ApiError(_INVALID_CREDENTIALS, 401)

	return {
		"user": {
			"id": user.id,
			"email": user.email,
			"name": user.name,
		},
		"access_token": create_access_token(identity=str(user.id)),
		"refresh_token": create_refresh_token(identity=str(user.id)),
	}
