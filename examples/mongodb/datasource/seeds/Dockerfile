FROM mongo

COPY . .

CMD mongoimport --host mongo --db travel_db --collection users --type json --file ./users.json --jsonArray && \
    mongoimport --host mongo --db travel_db --collection destinations --type json --file ./destinations.json --jsonArray && \
    mongoimport --host mongo --db travel_db --collection bookings --type json --file ./bookings.json --jsonArray && \
    mongoimport --host mongo --db travel_db --collection reviews --type json --file ./reviews.json --jsonArray && \
    mongoimport --host mongo --db travel_db --collection payments --type json --file ./payments.json --jsonArray
