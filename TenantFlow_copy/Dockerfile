# Use a base Flutter image
FROM cirrusci/flutter:stable AS build

# Set environment variables to avoid network issues
ENV PUB_HOSTED_URL=https://pub.dev
ENV FLUTTER_STORAGE_BASE_URL=https://storage.googleapis.com

# Set working directory
WORKDIR /app

# Copy Flutter project files
COPY . .

# Run Flutter pub get
RUN flutter pub get

# Build the web app
RUN flutter build web

# Use Nginx to serve the Flutter app
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]