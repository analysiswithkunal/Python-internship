# Question 1
#making and calling an weather API
import requests

def weather_data(city):
    url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid=402e6df2c2b14890d701d65ef40741ad&units=metric"
    
    try:
            response = requests.get(url)
            response.raise_for_status()
            data = response.json()
            for keys,value in data['main'].items():
                print(f"{keys.capitalize()}: {value}")
    except requests.exceptions.RequestException as e:
            print(e)
        
city = input("enter your city: ")
weather_data(city)

# Question 2
# Rock paper and scicessors
import random
choices = ["rock","paper","scicssors"]
for i in range(5):
    user_choice = input("Enter your choice : ").lower()
    computer_choice = random.choice(choices)
    print(f"Computer choice: {computer_choice}")
    
user_score = 0
computer_score = 0

if user_choice == computer_choice:
    print("tie!!")
elif((user_choice=="rock" and computer_choice=="scicssors") or
     (user_choice=="scicssors" and computer_choice=="paper") or
     (user_choice=="paper" and computer_choice=="rock")):
    print("you win!!")
    
    user_score+=1
else:
    print("Computer wins!!")
    computer_score+=1

print(f"final score - you:{user_score},Computer:{computer_score}")

# Question 3
# Calling an another API by python
# Calling newsAPI using newsAPI library
from newsapi import NewsApiClient
import os
newsapi = NewsApiClient(api_key='a98e880278c54a05af69495863523203')
articles = newsapi.get_top_headlines(
    country = 'in',
    category = 'technology',
    language = 'en',
    page_size = 10
)
print("\n"+"="*70)
print(" 📰 LATEST TECHNOLOGY NEWS FROM INDIA ")
print("="*70,"\n")

for i,article in enumerate(articles['articles'],1):
    print(f"🔹 Article #{i}")
    print(f" Title: {article['title']}")
    print(f"   Source: {article['source']['name']}")
    print(f"   Published: {article['publishedAt'][:10]} {article['publishedAt'][11:16]}")
    print(f"   URL: {article['url']}")
    print("-"*70)
