# Publishing Canastracker to Google Play Store

This guide walks you through the complete process of publishing Canastracker to the Google Play Store.

## Prerequisites

### 1. Google Play Developer Account
- **Cost**: One-time $25 USD registration fee
- **Sign up**: https://play.google.com/console/signup
- **Requirements**:
  - Google account (personal or organization)
  - Valid payment method
  - Phone number for verification
  - If personal account (after Nov 2023): Must complete 14-day closed testing before public release

### 2. Time Investment
- **Initial setup**: 2-4 hours
- **Review time**: Few hours to 7 days (typically 1-3 days)
- **First-time accounts**: Additional 14-day closed testing period required

---

## Part 1: Prepare Your App

### Step 1.1: Update Application ID

**Current Issue**: The app uses `com.example.canastracker` (not allowed on Play Store)

**Fix**: Edit `android/app/build.gradle`

```gradle
android {
    namespace "com.yourcompany.canastracker"  // Change this

    defaultConfig {
        applicationId "com.yourcompany.canastracker"  // Change this
        minSdkVersion 21
        targetSdkVersion 35  // Must be 35+ for 2025
        versionCode 2
        versionName "1.1.0"
    }
}
```

**Recommendation**: Use a reverse domain format like:
- `com.stiksy.canastracker` (if you own stiksy.com)
- `io.github.stiksy.canastracker` (using GitHub username)
- `br.com.yourname.canastracker` (Brazilian domain)

### Step 1.2: Create Release Signing Key

Google Play requires apps to be signed with a release key (not debug key).

**Generate keystore:**

```bash
keytool -genkey -v -keystore ~/canastracker-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias canastracker
```

You'll be prompted for:
- Keystore password (save this securely!)
- Name, organization, city, state, country
- Key password (can be same as keystore password)

**CRITICAL**: Back up this `.jks` file and passwords! You cannot update your app without them.

### Step 1.3: Configure Signing

Create `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=canastracker
storeFile=/Users/yourusername/canastracker-release-key.jks
```

**Add to .gitignore:**
```bash
echo "android/key.properties" >> .gitignore
```

Edit `android/app/build.gradle`:

```gradle
// Add before 'android {' block
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release  // Change from debug to release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### Step 1.4: Update Target SDK (Required for 2025)

**Google Play Requirement**: As of August 31, 2025, apps must target Android 15 (API 35) or higher.

Check your Flutter SDK version:
```bash
flutter --version
```

If you need to update:
```bash
flutter upgrade
```

The target SDK is automatically set by Flutter based on your Flutter version. Verify in `android/app/build.gradle`:
```gradle
targetSdkVersion flutter.targetSdkVersion  // Should resolve to 35+
```

### Step 1.5: Build App Bundle (AAB)

Google Play requires **App Bundles** (not APKs) for new apps.

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**Verify the bundle:**
```bash
ls -lh build/app/outputs/bundle/release/app-release.aab
```

---

## Part 2: Create Privacy Policy

**Requirement**: All apps must have a privacy policy, even if they don't collect data.

### What Canastracker Collects

Based on the code:
- ✅ **Local data only**: Player names, game scores, teams
- ✅ **No internet permissions**: No data sent anywhere
- ✅ **No personal info**: No email, phone, location, etc.
- ✅ **No ads or analytics**: No third-party trackers

### Privacy Policy Options

**Option 1: Use a generator**
- https://www.privacypolicygenerator.info/
- https://www.termsfeed.com/privacy-policy-generator/
- https://app-privacy-policy-generator.firebaseapp.com/

**Option 2: Host on GitHub**

Create `PRIVACY_POLICY.md` in your repo:

```markdown
# Privacy Policy for Canastracker

Last updated: October 27, 2025

## Data Collection
Canastracker does not collect, transmit, or share any personal data. All game data (player names, scores, game history) is stored locally on your device only.

## Data Storage
- All data is stored locally using SQLite database
- No data is sent to external servers
- No internet connection required
- You can delete all data by uninstalling the app

## Permissions
Canastracker does not request any special Android permissions.

## Third-Party Services
Canastracker does not use any third-party analytics, advertising, or tracking services.

## Children's Privacy
Our app is safe for children as it does not collect any personal information.

## Changes to This Policy
We may update this policy. Any changes will be posted on this page.

## Contact
For questions about this privacy policy, create an issue on our GitHub repository:
https://github.com/stiksy/canastracker/issues
```

**Then publish it:**
- Commit to GitHub
- Get the URL: https://github.com/stiksy/canastracker/blob/main/PRIVACY_POLICY.md

Or use GitHub Pages for a nicer URL:
- Settings → Pages → Enable Pages from `main` branch
- URL: https://stiksy.github.io/canastracker/PRIVACY_POLICY

---

## Part 3: Create Play Console Listing

### Step 3.1: Create New App

1. Go to https://play.google.com/console/
2. Click **"Create app"**
3. Fill in:
   - **App name**: Canastracker
   - **Default language**: Portuguese (Brazil)
   - **App or game**: Game
   - **Free or paid**: Free
   - Accept declarations

### Step 3.2: Store Listing

Navigate to **Store presence → Main store listing**

#### Required Information:

**App name**: Canastracker

**Short description** (80 chars max):
```
Contador de pontos para Canastra - o jogo de cartas brasileiro
```

**Full description** (4000 chars max):
```
Canastracker é o aplicativo definitivo para acompanhar a pontuação em partidas de Canastra, o tradicional jogo de cartas brasileiro.

🃏 RECURSOS PRINCIPAIS

• Gerenciamento de Jogadores: Crie e gerencie jogadores com estatísticas persistentes
• Configuração de Equipes: Suporte para 2-4 equipes com seleção múltipla de jogadores
• Baralhos Configuráveis: Jogue com 1-4 baralhos (padrão: 2)
• Pontuação Automática: Todos os cálculos baseados nas regras brasileiras de Canastra
• Histórico Completo: Visualize todas as partidas concluídas e em andamento
• Retomada Automática: Carrega automaticamente partidas em andamento

📊 REGRAS BRASILEIRAS DE CANASTRA

• Canastras Limpas: 200 pontos
• Canastras Sujas: 100 pontos
• 3 Vermelhos: +100 pontos cada (sempre positivo)
• 3 Pretos: -100 pontos cada (penalidade)
• Batida: 100 pontos bônus
• Meta: 3000 pontos

✨ FUNCIONALIDADES INTELIGENTES

• Validação Global de 3s: Impede entradas inválidas baseadas no número de baralhos
• Detalhamento de Pontos: Veja cálculos em tempo real
• Interface em Português: Design Material 3 moderno
• Sem Internet: Funciona 100% offline
• Sem Anúncios: Experiência limpa e focada

🎯 PERFEITO PARA

• Reuniões de família
• Noites de jogo com amigos
• Torneios de Canastra
• Qualquer um que queira focar no jogo, não na matemática!

📱 COMO USAR

1. Adicione jogadores no menu principal
2. Crie uma nova partida e configure as equipes
3. Entre as pontuações de cada rodada
4. O app calcula e rastreia tudo automaticamente!

Canastracker torna suas partidas de Canastra mais organizadas e agradáveis. Baixe agora e nunca mais perca o placar!
```

**App icon**: Already set (512x512 PNG required - use your app_icon.png)

**Feature graphic**: 1024x500 PNG
- Design recommendation: Cards theme with "Canastracker" text
- Can create with Canva, Figma, or Photoshop

**Phone screenshots**: Minimum 2, maximum 8 (PNG or JPEG)
- Required size: 16:9 or 9:16 aspect ratio
- Minimum dimension: 320px
- Maximum dimension: 3840px

**To capture screenshots:**
```bash
# Run app in emulator/device
flutter run

# Use Android Studio or adb to capture screenshots
# Or take photos of actual device
```

Recommended screenshots:
1. Home screen showing stats
2. New game setup screen
3. Round entry screen with score breakdown
4. Game history screen
5. Active game screen

**7-inch tablet screenshots**: Optional but recommended

**10-inch tablet screenshots**: Optional

**App category**: Games → Card

**Tags**: Optional (e.g., "card game", "score tracker", "canastra")

**Contact details**:
- Email: your-email@example.com (required)
- Phone: optional
- Website: https://github.com/stiksy/canastracker

**Privacy Policy URL**:
- Your privacy policy URL from Part 2

### Step 3.3: Data Safety

Navigate to **Store presence → Data safety**

**Answer these questions**:

1. **Does your app collect or share user data?**
   - Select: **No, we don't collect or share any user data**

2. **Is your app's data safety section accurate?**
   - Confirm: Yes

Since Canastracker stores everything locally and has no internet permission, you can confidently state no data collection.

### Step 3.4: Content Rating

Navigate to **Store presence → Content rating**

1. Fill out the questionnaire:
   - **Category**: Utility, Productivity, Communication, or Other
   - **No violence**: ✓
   - **No sexual content**: ✓
   - **No drugs/alcohol**: ✓
   - **No gambling**: ✓ (it's a score tracker, not gambling)

2. Expected rating: **Everyone** or **Everyone 10+**

### Step 3.5: Target Audience and Content

Navigate to **Store presence → Target audience and content**

1. **Target age groups**:
   - Select: Everyone (or specific age ranges)

2. **Do you have a Designed for Families program participation?**
   - Select: No (unless you want to target children specifically)

3. **Store presence**:
   - For Brazil specifically: May be required to comply with Brazilian regulations
   - Consider selecting Brazil as primary market

---

## Part 4: Testing (Required for New Accounts)

If your account was created after November 13, 2023, you must conduct closed testing for 14 days with at least 20 testers before public release.

### Step 4.1: Create Closed Testing Track

1. Navigate to **Testing → Closed testing**
2. Click **Create new release**
3. Upload your `app-release.aab`
4. Release name: "v1.1.0 Beta"
5. Release notes (in Portuguese):
```
Primeira versão beta do Canastracker

• Pontuação automática para Canastra
• Suporte para 2-4 equipes
• Histórico de partidas
• Interface em português
```

### Step 4.2: Create Tester List

1. Go to **Testing → Closed testing → Testers**
2. Create a list: "Beta Testers"
3. Add testers via:
   - Email addresses (Google accounts)
   - CSV upload
   - Or share opt-in URL with friends/family

**Minimum**: 20 testers required for new accounts

### Step 4.3: Share with Testers

1. Copy the opt-in URL
2. Share with friends, family, or post on social media
3. Testers install via Play Store link
4. Collect feedback for 14 days

---

## Part 5: Production Release

After testing period (or immediately if not required):

### Step 5.1: Create Production Release

1. Navigate to **Release → Production**
2. Click **Create new release**
3. **App integrity**:
   - Enroll in **Play App Signing** (recommended)
   - Google manages your signing key for you
   - Provides additional security
4. Upload `app-release.aab`
5. Release name: "1.1.0"
6. Release notes (Portuguese):
```
🎉 Lançamento Oficial do Canastracker v1.1.0

✨ Novidades:
• Terminologia aprimorada em português brasileiro
• Valores de cartas ajustados (Joker: 20, Ás: 15, 2: 10)
• Requisitos de abertura atualizados (45/75/90 pontos)
• Detalhamento de pontuação mais claro
• Interface totalmente consistente em português

📊 Recursos:
• Pontuação automática para Canastra
• Suporte para 2-4 equipes
• Histórico completo de partidas
• Validação inteligente de cartas
• 100% offline - sem internet necessária

Obrigado por usar o Canastracker!
```

7. Review release details
8. Click **Review release**
9. Review all information
10. Click **Start rollout to Production**

### Step 5.2: Rollout Options

- **Staged rollout**: Start with 20% of users, gradually increase
  - Safer for detecting critical bugs
  - Recommended for first release

- **Full rollout**: Release to 100% immediately
  - Faster user acquisition
  - Higher risk if bugs exist

### Step 5.3: Countries/Regions

Navigate to **Release → Production → Countries/regions**

**Recommendations**:
- Start with Brazil (primary market)
- Add Portugal (Portuguese-speaking)
- Later expand globally if desired

---

## Part 6: Post-Launch

### Monitor Your App

1. **Dashboard**: Check installs, crashes, ratings
2. **User feedback**: Respond to reviews (good practice)
3. **Crashes & ANRs**: Monitor for issues
4. **Performance**: Check app vitals

### Updating Your App

When releasing updates:

1. Update `pubspec.yaml`:
   ```yaml
   version: 1.2.0+3  # Increment both version and build number
   ```

2. Rebuild:
   ```bash
   flutter build appbundle --release
   ```

3. Upload to Play Console:
   - Production → Create new release
   - Upload new AAB
   - Add release notes
   - Roll out

### Marketing & Growth

- Share on social media
- Ask users to rate the app
- Respond to reviews promptly
- Monitor analytics
- Consider creating a website

---

## Checklist Summary

### Before Submission
- [ ] Google Play Developer account ($25)
- [ ] Updated application ID (not com.example.*)
- [ ] Created release signing key
- [ ] Configured signing in build.gradle
- [ ] Target SDK 35+ (Android 15)
- [ ] Built AAB file
- [ ] Created privacy policy (published online)
- [ ] Created feature graphic (1024x500)
- [ ] Captured screenshots (minimum 2)
- [ ] Prepared app descriptions (Portuguese)

### Play Console Setup
- [ ] Created app in Play Console
- [ ] Completed Store Listing
- [ ] Filled Data Safety form
- [ ] Completed Content Rating questionnaire
- [ ] Set Target Audience
- [ ] Added privacy policy URL
- [ ] Set contact email

### Testing (if new account)
- [ ] Created closed testing track
- [ ] Added 20+ testers
- [ ] Released beta for 14 days
- [ ] Collected feedback

### Production Release
- [ ] Enrolled in Play App Signing
- [ ] Uploaded final AAB
- [ ] Set release notes
- [ ] Selected countries/regions
- [ ] Reviewed all details
- [ ] Submitted for review

---

## Estimated Timeline

| Stage | Duration | Notes |
|-------|----------|-------|
| Setup & Preparation | 2-4 hours | One-time setup |
| Account Creation | Instant | If new, requires ID verification |
| Closed Testing | 14 days | Only for new accounts after Nov 2023 |
| Review & Publishing | 1-7 days | Usually 1-3 days |
| **Total (new account)** | **15-21+ days** | Including mandatory testing |
| **Total (established account)** | **1-7 days** | No testing requirement |

---

## Common Issues & Solutions

### Issue: "Package name already exists"
**Solution**: Change applicationId in build.gradle to unique name

### Issue: "Release is not signed"
**Solution**: Verify key.properties path and signing configuration

### Issue: "Target SDK too low"
**Solution**: Update Flutter SDK: `flutter upgrade`, then rebuild

### Issue: "Screenshots don't meet requirements"
**Solution**: Ensure 16:9 or 9:16 ratio, minimum 320px dimension

### Issue: "Privacy policy URL invalid"
**Solution**: Must be HTTPS, publicly accessible, no login required

### Issue: "Data safety form incomplete"
**Solution**: Answer all questions, even if you don't collect data

---

## Resources

- **Play Console**: https://play.google.com/console/
- **Google Play Policies**: https://play.google.com/about/developer-content-policy/
- **Flutter Publishing Guide**: https://docs.flutter.dev/deployment/android
- **App Signing**: https://developer.android.com/studio/publish/app-signing
- **Play Console Help**: https://support.google.com/googleplay/android-developer

---

## Getting Help

If you need assistance:

1. **Play Console Help Center**: https://support.google.com/googleplay/android-developer
2. **Flutter Community**: https://flutter.dev/community
3. **Stack Overflow**: Tag questions with `flutter` and `google-play`
4. **r/androiddev**: Reddit community for Android developers

---

**Good luck with your launch! 🚀**

Remember: First app launches take time to set up correctly, but subsequent updates are much faster. Take your time with the initial setup to ensure everything is correct.
