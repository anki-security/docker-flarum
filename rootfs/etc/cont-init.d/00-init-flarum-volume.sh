#!/usr/bin/with-contenv bash

echo "Checking Flarum installation..."

# Check if Flarum is already installed in the volume
if [ ! -f "/opt/flarum/composer.json" ] || [ ! -f "/opt/flarum/flarum" ]; then
    echo "Flarum not found in volume. Installing Flarum ${FLARUM_VERSION}..."
    
    # Ensure directory exists and has correct ownership
    mkdir -p /opt/flarum
    chown -R "${PUID}:${PGID}" /opt/flarum
    cd /opt/flarum
    
    # Create Flarum project
    echo "Creating Flarum project..."
    s6-setuidgid "${PUID}:${PGID}" composer create-project flarum/flarum . --no-install --stability=beta
    
    # Require specific Flarum version
    echo "Setting Flarum version to ${FLARUM_VERSION}..."
    s6-setuidgid "${PUID}:${PGID}" composer require "flarum/core:${FLARUM_VERSION}" --no-install
    
    # Install all dependencies
    echo "Installing Composer dependencies..."
    s6-setuidgid "${PUID}:${PGID}" composer install --no-dev --optimize-autoloader
    
    # Set final permissions
    chown -R "${PUID}:${PGID}" /opt/flarum
    
    echo "Flarum ${FLARUM_VERSION} installation complete!"
    
elif [ ! -d "/opt/flarum/vendor" ] || [ -z "$(ls -A /opt/flarum/vendor 2>/dev/null)" ]; then
    echo "Flarum found but vendor directory missing. Installing dependencies..."
    cd /opt/flarum
    chown -R "${PUID}:${PGID}" /opt/flarum
    s6-setuidgid "${PUID}:${PGID}" composer install --no-dev --optimize-autoloader
    echo "Dependencies installed!"
    
else
    echo "Flarum installation found and appears complete."
    
    # Ensure correct permissions
    chown -R "${PUID}:${PGID}" /opt/flarum
fi

echo "Flarum ready!"
