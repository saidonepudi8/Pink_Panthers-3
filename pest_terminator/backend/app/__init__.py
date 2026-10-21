from pathlib import Path

import click
from flask import Flask
from flask_cors import CORS

from app.config import Config
from app.errors import register_error_handlers
from app.extensions import db, jwt


def create_app(config_class=Config):
	# Create Flask app and import config settings
	app = Flask(__name__)
	app.config.from_object(config_class)

	if app.config["SQLALCHEMY_DATABASE_URI"].startswith("sqlite:"):
		Path(app.instance_path).mkdir(parents=True, exist_ok=True)

	db.init_app(app)
	jwt.init_app(app)
	CORS(app, origins=app.config["CORS_ORIGINS"])

	from app.features.auth.models import User
	from app.features.auth.routes import auth_bp

    # Register Auth blueprint
	app.register_blueprint(auth_bp)
	register_error_handlers(app)

    # CLI command for us in case we want to create DB manually
	@app.cli.command("init-db")
	def init_db_command():
		with app.app_context():
			db.create_all()
		click.echo("Database tables created.")

    # Automatic creation of DB tables
	with app.app_context():
		db.create_all()

	return app
