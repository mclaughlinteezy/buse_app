from django.urls import path
from .views import login_view, transactions_view

urlpatterns = [
    path('login/', login_view, name='login'),
    path('transactions/', transactions_view, name='transactions'),
]
