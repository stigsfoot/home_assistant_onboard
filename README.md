# Home Assistant Onboard (Demo App)

## For now, this is a Flutter+Firebase Demo App to demonstrate Firebase Privacy Extension

The Home Assistant Scheduler is a proof of concept, expands upon my [Udacity AI Nanodegree Capstone](https://github.com/stigsfoot/Udacity-Nanodegrees/tree/master/Machine%20Learning/capstone).

The Home Assistant Scheduler is a proof of concept to enable a user (homeowner) to manually log the installation date of maintenance items in a home (internal/external HVAC, roof etc.) through an onboarding flow, see their maintenance reminder preferences listed, and be able to purge that data, including their profile permanently from the system when they need to.

### 3 core objectives

**Authenticate** - Firebase Auth (Email/Google/Anonym)

**Onboarding** - Via the Flutter UI, select their preferences for home artifacts inside and outside their home they’d like to track. For example HVAC (last serviced, next service), Roof (date installed, next inspection), etc.

**Deletion** - Leverage Firebase Delete User Data extension (Cloud Firestore paths, Recursive) to honor an authenticated users' request to purge their information.

## Installation

TODO: Describe the installation process

## Usage

git clone https://github.com/stigsfoot/home_assistant_onboard.git home_assistant_onboard
cd home_assistant_onboard

flutter run

## Contributing

See [Contributing.md](CONTRIBUTING.md) guidelines.

1. Clone or fork it!
2. Create your feature branch: `git checkout -b home_assistant_onboard`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin home_assistant_onboard`
5. Submit a pull request :D

## Created & Maintained By

[Noble Ackerson](https://nobles.page) (@stigsfoot)

> If you found this project helpful, you decide to use it to track stuff that needs maintenance in your home, or if you learned something, [consider sponsoring this project](patreon.com/stigsfoot)

## Credits

Props to Jeff Delaney sign up as a Pro and support his [fireship.io courses](https://fireship.io).
