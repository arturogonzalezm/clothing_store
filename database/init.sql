-- Ensure the 'glamify_role' role exists
DO
$do$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles
                              WHERE rolname = 'glamify_role') THEN
            CREATE ROLE glamify_role;
        END IF;
    END
$do$;

-- Create the glamify database if it does not exist
DO
$do$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_database
                              WHERE datname = 'glamify') THEN
            CREATE DATABASE glamify OWNER glamify_role;
        END IF;
    END
$do$;

-- Create a new user with a password if it does not exist
DO
$do$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles
                              WHERE rolname = 'glamify_role') THEN
            CREATE USER glamify_user WITH ENCRYPTED PASSWORD 'securepassword';
        END IF;
    END
$do$;


-- Grant all privileges on the glamify database to the glamify_user
GRANT ALL PRIVILEGES ON DATABASE glamify TO glamify_user;

-- Connect to the glamify database (Note: This should be run manually in psql)
\c glamify

-- Create the Users table
CREATE TABLE IF NOT EXISTS Users (
                                     user_id SERIAL PRIMARY KEY,
                                     name VARCHAR(100) NOT NULL,
                                     email VARCHAR(255) UNIQUE NOT NULL,
                                     phone_number VARCHAR(20),
                                     password_hash TEXT NOT NULL,
                                     created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                     updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Optional: Create a trigger to automatically update the 'updated_at' field on record updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON Users
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create the UserMeasurements table
CREATE TABLE IF NOT EXISTS UserMeasurements (
                                                measurement_id SERIAL PRIMARY KEY,
                                                user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                                height DECIMAL(5, 2) NOT NULL,
                                                weight DECIMAL(5, 2) NOT NULL,
                                                chest DECIMAL(5, 2),
                                                waist DECIMAL(5, 2),
                                                hip DECIMAL(5, 2),
                                                shoulder_width DECIMAL(5, 2),
                                                created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                                updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the Clothes table
CREATE TABLE IF NOT EXISTS Clothes (
                                       clothing_id SERIAL PRIMARY KEY,
                                       name VARCHAR(255) NOT NULL,
                                       category VARCHAR(50),
                                       size VARCHAR(10),
                                       color VARCHAR(50),
                                       material VARCHAR(100),
                                       price DECIMAL(10, 2),
                                       inventory_count INT DEFAULT 0,
                                       image_url TEXT,
                                       created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                       updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the ClothingMeasurements table
CREATE TABLE IF NOT EXISTS ClothingMeasurements (
                                                    clothing_measurement_id SERIAL PRIMARY KEY,
                                                    clothing_id INT REFERENCES Clothes(clothing_id) ON DELETE CASCADE,
                                                    chest DECIMAL(5, 2),
                                                    waist DECIMAL(5, 2),
                                                    hip DECIMAL(5, 2),
                                                    shoulder_width DECIMAL(5, 2),
                                                    length DECIMAL(5, 2),
                                                    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                                    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserPreferences table
CREATE TABLE IF NOT EXISTS UserPreferences (
                                               preference_id SERIAL PRIMARY KEY,
                                               user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                               preferred_color VARCHAR(50),
                                               preferred_style VARCHAR(100),
                                               created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                               updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserLikedClothes table
CREATE TABLE IF NOT EXISTS UserLikedClothes (
                                                liked_id SERIAL PRIMARY KEY,
                                                user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                                clothing_id INT REFERENCES Clothes(clothing_id) ON DELETE CASCADE,
                                                created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserDislikedClothes table
CREATE TABLE IF NOT EXISTS UserDislikedClothes (
                                                   disliked_id SERIAL PRIMARY KEY,
                                                   user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                                   clothing_id INT REFERENCES Clothes(clothing_id) ON DELETE CASCADE,
                                                   created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserSessions table
CREATE TABLE IF NOT EXISTS UserSessions (
                                            session_id SERIAL PRIMARY KEY,
                                            user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                            session_token TEXT NOT NULL,
                                            created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                            expires_at TIMESTAMPTZ NOT NULL
);

-- Create the Notifications table
CREATE TABLE IF NOT EXISTS Notifications (
                                             notification_id SERIAL PRIMARY KEY,
                                             user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                             message TEXT NOT NULL,
                                             status VARCHAR(50) DEFAULT 'pending',
                                             created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                             sent_at TIMESTAMPTZ
);

-- Create the PaymentMethods table
CREATE TABLE IF NOT EXISTS PaymentMethods (
                                              payment_id SERIAL PRIMARY KEY,
                                              user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                              card_number VARCHAR(20) NOT NULL,
                                              card_holder_name VARCHAR(100) NOT NULL,
                                              expiration_date DATE NOT NULL,
                                              cvv VARCHAR(5) NOT NULL,
                                              created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                              updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the ShippingAddresses table
CREATE TABLE IF NOT EXISTS ShippingAddresses (
                                                 address_id SERIAL PRIMARY KEY,
                                                 user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                                 address_line1 VARCHAR(255) NOT NULL,
                                                 address_line2 VARCHAR(255),
                                                 city VARCHAR(100) NOT NULL,
                                                 state VARCHAR(100) NOT NULL,
                                                 zip_code VARCHAR(10) NOT NULL,
                                                 country VARCHAR(100) NOT NULL,
                                                 created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                                 updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the Orders table
CREATE TABLE IF NOT EXISTS Orders (
                                      order_id SERIAL PRIMARY KEY,
                                      user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                      total_price DECIMAL(10, 2) NOT NULL,
                                      status VARCHAR(50) DEFAULT 'pending',
                                      created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                      updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the OrderItems table
CREATE TABLE IF NOT EXISTS OrderItems (
                                          order_item_id SERIAL PRIMARY KEY,
                                          order_id INT REFERENCES Orders(order_id) ON DELETE CASCADE,
                                          clothing_id INT REFERENCES Clothes(clothing_id) ON DELETE CASCADE,
                                          quantity INT NOT NULL,
                                          created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                          updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the Reviews table
CREATE TABLE IF NOT EXISTS Reviews (
                                       review_id SERIAL PRIMARY KEY,
                                       user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                       clothing_id INT REFERENCES Clothes(clothing_id) ON DELETE CASCADE,
                                       rating INT NOT NULL,
                                       review TEXT,
                                       created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                       updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the CartItems table
CREATE TABLE IF NOT EXISTS CartItems (
                                         cart_item_id SERIAL PRIMARY KEY,
                                         user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                         clothing_id INT REFERENCES Clothes(clothing_id) ON DELETE CASCADE,
                                         quantity INT NOT NULL,
                                         created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                         updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserCart table
CREATE TABLE IF NOT EXISTS UserCart (
                                        cart_id SERIAL PRIMARY KEY,
                                        user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                        updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserCartItems table
CREATE TABLE IF NOT EXISTS UserCartItems (
                                             cart_item_id SERIAL PRIMARY KEY,
                                             cart_id INT REFERENCES UserCart(cart_id) ON DELETE CASCADE,
                                             clothing_id INT REFERENCES Clothes(clothing_id) ON DELETE CASCADE,
                                             quantity INT NOT NULL,
                                             created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                             updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserOutfits table
CREATE TABLE IF NOT EXISTS UserOutfits (
                                           outfit_id SERIAL PRIMARY KEY,
                                           user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                           name VARCHAR(255) NOT NULL,
                                           created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                           updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the OutfitItems table
CREATE TABLE IF NOT EXISTS OutfitItems (
                                           outfit_item_id SERIAL PRIMARY KEY,
                                           outfit_id INT REFERENCES UserOutfits(outfit_id) ON DELETE CASCADE,
                                           clothing_id INT REFERENCES Clothes(clothing_id) ON DELETE CASCADE,
                                           created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                                           updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserOutfitLikes table
CREATE TABLE IF NOT EXISTS UserOutfitLikes (
                                               like_id SERIAL PRIMARY KEY,
                                               user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                               outfit_id INT REFERENCES UserOutfits(outfit_id) ON DELETE CASCADE,
                                               created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserOutfitDislikes table
CREATE TABLE IF NOT EXISTS UserOutfitDislikes (
                                                  dislike_id SERIAL PRIMARY KEY,
                                                  user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                                  outfit_id INT REFERENCES UserOutfits(outfit_id) ON DELETE CASCADE,
                                                  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserOutfitComments table
CREATE TABLE IF NOT EXISTS UserOutfitComments (
                                                 comment_id SERIAL PRIMARY KEY,
                                                 user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                                 outfit_id INT REFERENCES UserOutfits(outfit_id) ON DELETE CASCADE,
                                                 comment TEXT NOT NULL,
                                                 created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the UserOutfitRatings table
CREATE TABLE IF NOT EXISTS UserOutfitRatings (
                                                 rating_id SERIAL PRIMARY KEY,
                                                 user_id INT REFERENCES Users(user_id) ON DELETE CASCADE,
                                                 outfit_id INT REFERENCES UserOutfits(outfit_id) ON DELETE CASCADE,
                                                 rating INT NOT NULL,
                                                 created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

