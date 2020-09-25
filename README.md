# Home Assistant Onboard (Demo App)
 ## For now, this is a Flutter+Firebase Demo App to demonstrate Firebase Privacy Extension
The Home Assistant Scheduler is a proof of concept, expands upon my [Udacity AI Nanodegree Capstone](https://github.com/stigsfoot/Udacity-Nanodegrees/tree/master/Machine%20Learning/capstone). This Flutter app demonstrates a manual flow for a homeowner to log installation dates and maintenance items in a home (internal/external) and be able to purge that data from the system permanently when they need to.

## 3 core objectives

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

1. Clone or fork it!
2. Create your feature branch: `git checkout -b home_assistant_onboard`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin home_assistant_onboard`
5. Submit a pull request :D


## Credits

Props to Jeff Delaney sign up as a Pro and support his [fireship.io courses](https://fireship.io).


