import requests
from time import sleep
from bs4 import BeautifulSoup


FRONTEND_URL = "http://minitwit:5000"

while True:
    # This is a hack...
    r = requests.get(FRONTEND_URL)
    if "mysql.connector.errors.InterfaceError" in r.text:
        print("Waiting another 5s for DB to be initialized...")
        sleep(5)
    else:
        break


def test_thirty_msgs_on_frontpage():
    r = requests.get(FRONTEND_URL)
    soup = BeautifulSoup(r.content, "html.parser")
    tweets = soup.find("ul", {"class": "messages"}).findAll("strong")

    assert len(tweets) == 30


def test_first_tweeters_on_frontpage():
    r = requests.get(FRONTEND_URL)
    soup = BeautifulSoup(r.content, "html.parser")
    tweeters = soup.find("ul", {"class": "messages"}).findAll("a")

    assert tweeters[0].text == "Johnnie Lesso"
    assert tweeters[1].text == "Sharmaine Abdelrahman"
    assert tweeters[2].text == "Dominga Barcenas"
    assert tweeters[3].text == "Kerry Passer"
