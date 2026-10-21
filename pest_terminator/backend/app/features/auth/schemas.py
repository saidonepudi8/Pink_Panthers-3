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

# Registration form validation
def validate_registration_payload(payload):
	if not isinstance(payload, dict):
		raise ApiError("A JSON object is required.", 422)

	name = payload.get("name")
	email = payload.get("email")
	password = payload.get("password")
	if not isinstance(name, str) or not name.strip():
		raise ApiError("Name is required.", 422)
	if len(name.strip()) > 120:
		raise ApiError("Name must be 120 characters or fewer.", 422)
	if not isinstance(email, str) or not _EMAIL_PATTERN.fullmatch(email.strip()):
		raise ApiError("A valid email address is required.", 422)
	if not isinstance(password, str) or not password.strip():
		raise ApiError("Password is required.", 422)
	if len(password) < 8:
		raise ApiError("Password must be at least 8 characters.", 422)

	return {
		"name": name.strip(),
		"email": email.strip().lower(),
		"password": password,
	}
