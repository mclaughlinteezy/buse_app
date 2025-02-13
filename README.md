# buse_app

Buse App 
Overview
Buse App is a mobile application built with Flutter for the frontend and Django for the backend, using PostgreSQL as the database.

Technologies Used
Frontend: Flutter (Dart)
Backend: Django (Python)
Database: PostgreSQL

Getting Started
1. Clone the Repository

  - git clone https://github.com/mclaughlinteezy/buse_app.git
  - cd buse_app

2. Running the Flutter Frontend
   Prerequisites:
   - Install Android Studio
   - Connect a physical device or start an emulator
    Run the Flutter App
   - cd frontend
   - flutter pub get    # Install dependencies
   -  flutter run        # Run the app

3. Running the Django Backend
   Prerequisites:
    - Install Python 3.x
    - Install PostgreSQL
    - Install virtualenv for a virtual Python environment
   Set Up Virtual Environment
    - cd backend
    - python -m venv venv
    - venv\Scripts\activate
   Install Dependencies
    - pip install -r requirements.txt
   Set Up Database
    - CREATE DATABASE buse_db;

4. Update backend/settings.py with your PostgreSQL credentials:
   - DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql',
            'NAME': 'buse_db',
            'USER': 'your_username',
            'PASSWORD': 'your_password',
            'HOST': 'localhost',
            'PORT': '5432',
                   }
                  }

5. Apply Migrations
   - python manage.py makemigrations
   - python manage.py migrate


6. Run the Backend Server
  - python manage.py runserver 0.0.0.0:8000



