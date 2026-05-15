CREATE TABLE categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE role_type AS ENUM (
    'ADMIN',
    'USER'
);

CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    role role_type NOT NULL DEFAULT 'USER',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_addresses (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,

    street VARCHAR(255) NOT NULL,

    number VARCHAR(20) NOT NULL,

    neighborhood VARCHAR(120) NOT NULL,

    city VARCHAR(120) NOT NULL,

    state VARCHAR(120) NOT NULL,

    zip_code VARCHAR(20) NOT NULL,

    complement VARCHAR(255),

    reference_point VARCHAR(255),

    is_default BOOLEAN NOT NULL DEFAULT FALSE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE products (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL ,
    stock INTEGER NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    category_id BIGINT REFERENCES categories(id) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    display_order INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_product_image_order
        UNIQUE(product_id, display_order)
);

CREATE TABLE carts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE cart_items (
    id BIGSERIAL PRIMARY KEY,

    cart_id BIGINT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,

    product_id BIGINT NOT NULL REFERENCES products(id),

    quantity INTEGER NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_cart_product
        UNIQUE(cart_id, product_id)
);

CREATE TYPE coupon_type AS ENUM (
    'PERCENTAGE',
    'FIXED'
);

CREATE TABLE coupons (
    id BIGSERIAL PRIMARY KEY,

    code VARCHAR(50) NOT NULL UNIQUE,

    type coupon_type NOT NULL,

    value NUMERIC(10,2) NOT NULL,

    minimum_order_value NUMERIC(10,2),

    usage_limit INTEGER,

    used_count INTEGER NOT NULL DEFAULT 0,

    active BOOLEAN NOT NULL DEFAULT TRUE,

    expires_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE order_status AS ENUM (
    'PENDING',
    'PAID',
    'SHIPPED',
    'DELIVERED',
    'CANCELLED'
);

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,

    user_id BIGINT NOT NULL REFERENCES users(id),

    coupon_id BIGINT REFERENCES coupons(id),

    status order_status NOT NULL DEFAULT 'PENDING',

    subtotal NUMERIC(10,2) NOT NULL,

    discount NUMERIC(10,2) NOT NULL DEFAULT 0,

    total NUMERIC(10,2) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id BIGSERIAL PRIMARY KEY,

    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,

    product_id BIGINT NOT NULL REFERENCES products(id),

    product_name VARCHAR(150) NOT NULL,

    unit_price NUMERIC(10,2) NOT NULL,

    quantity INTEGER NOT NULL,

    total_price NUMERIC(10,2) NOT NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_order_product
        UNIQUE(order_id, product_id)
);

CREATE TABLE order_addresses (
    id BIGSERIAL PRIMARY KEY,

    order_id BIGINT NOT NULL UNIQUE
        REFERENCES orders(id)
        ON DELETE CASCADE,

    street VARCHAR(255) NOT NULL,

    number VARCHAR(20) NOT NULL,

    neighborhood VARCHAR(120) NOT NULL,

    city VARCHAR(120) NOT NULL,

    state VARCHAR(120) NOT NULL,

    zip_code VARCHAR(20) NOT NULL,

    complement VARCHAR(255),

    reference_point VARCHAR(255),

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TYPE payment_status AS ENUM (
    'PENDING',
    'APPROVED',
    'FAILED',
    'REFUNDED'
);

CREATE TYPE payment_method AS ENUM (
    'PIX',
    'CREDIT_CARD'
);

CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,

    order_id BIGINT NOT NULL UNIQUE REFERENCES orders(id),

    method payment_method NOT NULL,

    status payment_status NOT NULL DEFAULT 'PENDING',

    amount NUMERIC(10,2) NOT NULL,

    transaction_id VARCHAR(255),

    paid_at TIMESTAMPTZ,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
