from urllib.parse import urlencode
from urllib.request import Request, urlopen

url = 'https://httpbin.org/post' # Set destination URL here
post_fields = {'weight': '100',
    'pickUpLocation': 'pickUpLocation',
    'dropOffLocation': 'dropOffLocation',}     # Set POST fields here

request = Request(url, urlencode(post_fields).encode())
json = urlopen(request).read().decode()
print(json)