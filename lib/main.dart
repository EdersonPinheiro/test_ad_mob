import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:test_ad_mob/admob_service.dart';

void main() {
  runApp(const MyApp());
  _initGoogleMobileAds();
}

Future<InitializationStatus> _initGoogleMobileAds() {
  // TODO: Initialize Google Mobile Ads SDK
  return MobileAds.instance.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBanner();
    loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdmobService.rewardedAdUnitId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                _rewardedAd = null;
              });
              _loadRewardedAd();
            },
          );

          setState(() {
            _rewardedAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdmobService.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              print("Foi");
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  void loadBanner() {
    BannerAd(
      adUnitId: AdmobService.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SafeArea(
              child: Stack(
                children: [
                  if (_bannerAd != null)
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                ],
              ),
            ),
            ElevatedButton(onPressed: () {
              showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text('Need a hint?'),
                  content: Text('Watch an Ad to get a hint!'),
                  actions: [
                    TextButton(
                      child: Text('cancel'.toUpperCase()),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Text('ok'.toUpperCase()),
                      onPressed: () {
                        Navigator.pop(context);
                        _rewardedAd?.show(
                          onUserEarnedReward: (_, reward) {
                            
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
            }, child: Text("Premium"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_interstitialAd != null) {
            _interstitialAd?.show();
            loadInterstitialAd();
          } else {
            print("Não foi");
          }
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
