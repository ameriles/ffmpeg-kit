#!/usr/bin/env node

const https = require('https');
const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const RELEASE_TAG = 'v2.0.0-video-lgpl';
const REPO = 'ameriles/ffmpeg-kit';
const IOS_BINARY = 'ffmpeg-kit-video-lgpl-ios.tar.gz';
const ANDROID_BINARY = 'ffmpeg-kit-video-lgpl-android.zip';

const iosDir = path.join(__dirname, '../ios');
const androidDir = path.join(__dirname, '../android/libs');

console.log('📦 Downloading FFmpeg Kit video-lgpl binaries...');

function download(url, dest) {
  return new Promise((resolve, reject) => {
    const file = fs.createWriteStream(dest);
    https.get(url, (response) => {
      if (response.statusCode === 302 || response.statusCode === 301) {
        // Follow redirect
        return download(response.headers.location, dest).then(resolve).catch(reject);
      }
      response.pipe(file);
      file.on('finish', () => {
        file.close();
        resolve();
      });
    }).on('error', (err) => {
      fs.unlink(dest, () => {});
      reject(err);
    });
  });
}

async function downloadAndExtract() {
  try {
    // Create directories
    if (!fs.existsSync(iosDir)) {
      fs.mkdirSync(iosDir, { recursive: true });
    }
    if (!fs.existsSync(androidDir)) {
      fs.mkdirSync(androidDir, { recursive: true });
    }

    // Check if already downloaded
    if (fs.existsSync(path.join(iosDir, 'ffmpegkit.framework')) &&
        fs.existsSync(path.join(androidDir, 'ffmpeg-kit.aar'))) {
      console.log('✅ Binaries already present, skipping download');
      return;
    }

    // Clean up any existing frameworks first
    const existingFrameworks = fs.readdirSync(iosDir).filter(f => f.endsWith('.framework'));
    existingFrameworks.forEach(f => {
      const fpath = path.join(iosDir, f);
      if (fs.existsSync(fpath)) {
        execSync(`rm -rf ${fpath}`);
      }
    });

    const baseUrl = `https://github.com/${REPO}/releases/download/${RELEASE_TAG}`;

    // Download iOS
    console.log('📱 Downloading iOS frameworks...');
    const iosTarPath = path.join(__dirname, IOS_BINARY);
    await download(`${baseUrl}/${IOS_BINARY}`, iosTarPath);
    console.log('📱 Extracting iOS frameworks...');
    execSync(`tar -xzf ${iosTarPath} -C ${iosDir} --strip-components=1`);
    fs.unlinkSync(iosTarPath);

    // Download Android
    console.log('🤖 Downloading Android AAR...');
    const androidZipPath = path.join(__dirname, ANDROID_BINARY);
    await download(`${baseUrl}/${ANDROID_BINARY}`, androidZipPath);
    console.log('🤖 Extracting Android AAR...');
    execSync(`unzip -q ${androidZipPath} -d ${path.dirname(androidDir)}`);

    // Move AAR to correct location
    const aarSource = path.join(path.dirname(androidDir), 'bundle-android-aar/ffmpeg-kit/ffmpeg-kit.aar');
    const aarDest = path.join(androidDir, 'ffmpeg-kit.aar');
    if (fs.existsSync(aarSource)) {
      fs.renameSync(aarSource, aarDest);
      // Cleanup
      execSync(`rm -rf ${path.join(path.dirname(androidDir), 'bundle-android-aar')}`);
    }
    fs.unlinkSync(androidZipPath);

    console.log('✅ Binaries downloaded and extracted successfully!');
  } catch (error) {
    console.error('❌ Failed to download binaries:', error.message);
    console.log('\n⚠️  You can manually download binaries from:');
    console.log(`   https://github.com/${REPO}/releases/tag/${RELEASE_TAG}`);
    process.exit(1);
  }
}

downloadAndExtract();
