#!/bin/bash
if [ -z "$ENCRYPTION_PASSWORD" ]; then
  echo "no password, stop here..."
else
  openssl aes-256-cbc -k $ENCRYPTION_PASSWORD -in fastlane/Certificates/ZplayAds_Distribute.p12.enc -d -a -out fastlane/Certificates/ZplayAds_Distribute.p12
  mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
  openssl aes-256-cbc -k $ENCRYPTION_PASSWORD -in fastlane/Certificates/ZplayAds_Distribute.mobileprovision.enc -d -a -out ~/Library/MobileDevice/Provisioning\ Profiles/ZplayAds_Distribute.mobileprovision
fi
