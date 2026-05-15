#chmod +x start.sh
export $(grep -v '^#' .env.local | xargs)
./mvnw spring-boot:run