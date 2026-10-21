from flask import Blueprint, jsonify, request

from app.features.auth.schemas import (
	validate_login_payload,
	validate_registration_payload,
)
from app.features.auth.service import login, register

# Var to store base API path
auth_bp = Blueprint("auth", __name__, url_prefix="/api/auth")

# HTTP Post route handling from frontend. 
@auth_bp.post("/login")
def login_route():
	payload = validate_login_payload(request.get_json(silent=True))
	return jsonify(login(payload)), 200

# HTTP Post route to handle user registration
@auth_bp.post("/register")
def register_route():
	payload = validate_registration_payload(request.get_json(silent=True))
	return jsonify(register(payload)), 201
