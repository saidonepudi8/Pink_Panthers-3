import re

from app.errors import ApiError

# Regex patten that matches frontend validation
_EMAIL_PATTERN = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")

# Validate creds against pattern. If invalid, return corresponding API error.
def validate_login_payload(payload):
	if not isinstance(payload, dict):
		raise ApiError("A JSON object is required.", 422)

	email = payload.get("email")
	password = payload.get("password")
	if not isinstance(email, str) or not _EMAIL_PATTERN.fullmatch(email.strip()):
		raise ApiError("A valid email address is required.", 422)
	if not isinstance(password, str) or not password.strip():
		raise ApiError("Password is required.", 422)

	return {"email": email.strip().lower(), "password": password}
