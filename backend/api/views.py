from django.contrib.auth import authenticate
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from djangoBUSE import settings
from .models import Transaction
from .serializers import TransactionSerializer
import uuid

def verify_user(username, password):

    return username == "admin" and password == "password"

@api_view(['POST'])
def login_view(request):
    username = request.data.get('username')
    password = request.data.get('password')


    if verify_user(username, password):

        api_key = settings.API_KEY


        return Response(
            {"message": "Login successful", "api_key": api_key},
            status=status.HTTP_200_OK
        )


    return Response({"message": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)
@api_view(['GET', 'POST'])

def transactions_view(request):

    api_key = request.headers.get('X-API-Key')


    if api_key != settings.API_KEY:
        return Response({"message": "Unauthorized, invalid or missing API key."}, status=status.HTTP_401_UNAUTHORIZED)


    if request.method == 'GET':
        transactions = Transaction.objects.all()
        serializer = TransactionSerializer(transactions, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    elif request.method == 'POST':
        serializer = TransactionSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
