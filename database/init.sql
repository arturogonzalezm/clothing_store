-- Ensure the 'glamify_role' role exists
DO
$do$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'glamify_role') THEN
            CREATE ROLE glamify_role;
        END IF;
    END
$do$;

-- Create the glamify database if it does not exist
DO
$do$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'glamify') THEN
            CREATE DATABASE glamify OWNER glamify_role;
        END IF;
    END
$do$;

-- Create a new user with a password if it does not exist
DO
$do$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'glamify_user') THEN
            CREATE USER glamify_user WITH ENCRYPTED PASSWORD 'securepassword';
        END IF;
    END
$do$;

-- Grant all privileges on the glamify database to the glamify_user
GRANT ALL PRIVILEGES ON DATABASE glamify TO glamify_user;

-- Connect to the glamify database (Note: This should be run manually in psql)
\c glamify

-- Create the users table
CREATE TABLE IF NOT EXISTS users (
    user_id SERIAL PRIMARY KEY,  -- This creates the primary key column named user_id
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    password_hash TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS items (
    id SERIAL NOT NULL,
    title VARCHAR(100),
    description VARCHAR(500),
    owner_id INTEGER,
    PRIMARY KEY (id),
    FOREIGN KEY(owner_id) REFERENCES users(user_id)  -- Referencing user_id in the users table
);


-- Optional: Create a trigger to automatically update the 'updated_at' field on record updates
CREATE OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Create the user_measurements table
CREATE TABLE IF NOT EXISTS user_measurements (
    measurement_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    height DECIMAL(5, 2) NOT NULL,
    weight DECIMAL(5, 2) NOT NULL,
    chest DECIMAL(5, 2),
    waist DECIMAL(5, 2),
    hip DECIMAL(5, 2),
    shoulder_width DECIMAL(5, 2),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the clothes table
CREATE TABLE IF NOT EXISTS clothes (
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

-- Create the clothing_measurements table
CREATE TABLE IF NOT EXISTS clothing_measurements (
    clothing_measurement_id SERIAL PRIMARY KEY,
    clothing_id INT REFERENCES clothes(clothing_id) ON DELETE CASCADE,
    chest DECIMAL(5, 2),
    waist DECIMAL(5, 2),
    hip DECIMAL(5, 2),
    shoulder_width DECIMAL(5, 2),
    length DECIMAL(5, 2),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_preferences table
CREATE TABLE IF NOT EXISTS user_preferences (
    preference_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    preferred_color VARCHAR(50),
    preferred_style VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_liked_clothes table
CREATE TABLE IF NOT EXISTS user_liked_clothes (
    liked_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    clothing_id INT REFERENCES clothes(clothing_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_disliked_clothes table
CREATE TABLE IF NOT EXISTS user_disliked_clothes (
    disliked_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    clothing_id INT REFERENCES clothes(clothing_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_sessions table
CREATE TABLE IF NOT EXISTS user_sessions (
    session_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    session_token TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMPTZ NOT NULL
);

-- Create the notifications table
CREATE TABLE IF NOT EXISTS notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    sent_at TIMESTAMPTZ
);

-- Create the payment_methods table
CREATE TABLE IF NOT EXISTS payment_methods (
    payment_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    card_number VARCHAR(20) NOT NULL,
    card_holder_name VARCHAR(100) NOT NULL,
    expiration_date DATE NOT NULL,
    cvv VARCHAR(5) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the shipping_addresses table
CREATE TABLE IF NOT EXISTS shipping_addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    zip_code VARCHAR(10) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    total_price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the order_items table
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id) ON DELETE CASCADE,
    clothing_id INT REFERENCES clothes(clothing_id) ON DELETE CASCADE,
    quantity INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the reviews table
CREATE TABLE IF NOT EXISTS reviews (
    review_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    clothing_id INT REFERENCES clothes(clothing_id) ON DELETE CASCADE,
    rating INT NOT NULL,
    review TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the cart_items table
CREATE TABLE IF NOT EXISTS cart_items (
    cart_item_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    clothing_id INT REFERENCES clothes(clothing_id) ON DELETE CASCADE,
    quantity INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_cart table
CREATE TABLE IF NOT EXISTS user_cart (
    cart_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_cart_items table
CREATE TABLE IF NOT EXISTS user_cart_items (
    cart_item_id SERIAL PRIMARY KEY,
    cart_id INT REFERENCES user_cart(cart_id) ON DELETE CASCADE,
    clothing_id INT REFERENCES clothes(clothing_id) ON DELETE CASCADE,
    quantity INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_outfits table
CREATE TABLE IF NOT EXISTS user_outfits (
    outfit_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the outfit_items table
CREATE TABLE IF NOT EXISTS outfit_items (
    outfit_item_id SERIAL PRIMARY KEY,
    outfit_id INT REFERENCES user_outfits(outfit_id) ON DELETE CASCADE,
    clothing_id INT REFERENCES clothes(clothing_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_outfit_likes table
CREATE TABLE IF NOT EXISTS user_outfit_likes (
    like_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    outfit_id INT REFERENCES user_outfits(outfit_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_outfit_dislikes table
CREATE TABLE IF NOT EXISTS user_outfit_dislikes (
    dislike_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    outfit_id INT REFERENCES user_outfits(outfit_id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_outfit_comments table
CREATE TABLE IF NOT EXISTS user_outfit_comments (
    comment_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    outfit_id INT REFERENCES user_outfits(outfit_id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Create the user_outfit_ratings table
CREATE TABLE IF NOT EXISTS user_outfit_ratings (
    rating_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(user_id) ON DELETE CASCADE,
    outfit_id INT REFERENCES user_outfits(outfit_id) ON DELETE CASCADE,
    rating INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
