using System;
using System.Collections;
using UnityEngine;
using GoogleMobileAds;
using GoogleMobileAds.Api;

// Example script showing how to invoke the Google Mobile Ads Unity plugin.
public class GoogleMobileAdsDemoScript : MonoBehaviour
{	
	private static bool loaded;
	private static InterstitialAd interstitial;
	private static string outputMessage = "";
	public static GameObject moreAG;
	
	void Start() 
	{
		moreAG = GameObject.Find("Canvas/MoreAG").gameObject;
		RequestInterstitial();
	}
	
	public static string OutputMessage
	{
		set { outputMessage = value; }
	}
	
	public void RequestInterstitial()
	{
		// Create an interstitial.
		if(interstitial == null || !loaded)
		{
			moreAG.SetActive(false);
			#if UNITY_EDITOR
			string adUnitId = "unused";
			#elif UNITY_ANDROID
			string adUnitId = "/6087/defy_gaming_apps";
			#elif UNITY_IPHONE
			string adUnitId = "/6087/defy_gaming_apps";
			#else
			string adUnitId = "unexpected_platform";
			#endif
			interstitial = new InterstitialAd(adUnitId);
			// Register for ad events.
			interstitial.AdLoaded += HandleInterstitialLoaded;
			interstitial.AdFailedToLoad += HandleInterstitialFailedToLoad;
			interstitial.AdOpened += HandleInterstitialOpened;
			interstitial.AdClosing += HandleInterstitialClosing;
			interstitial.AdClosed += HandleInterstitialClosed;
			interstitial.AdLeftApplication += HandleInterstitialLeftApplication;
			// Load an interstitial ad.
			interstitial.LoadAd(createAdRequest());
		}
		else
		{
			moreAG.SetActive(true);
		}
	}
	
	// Returns an ad request with custom ad targeting.
	private AdRequest createAdRequest()
	{
		return new AdRequest.Builder()
			//                .AddTestDevice(AdRequest.TestDeviceSimulator)
			//                .AddTestDevice("0123456789ABCDEF0123456789ABCDEF")
			//                .AddKeyword("game")
			//                .SetGender(Gender.Male)
			//                .SetBirthday(new DateTime(1985, 1, 1))
			//                .TagForChildDirectedTreatment(false)
			//                .AddExtra("color_bg", "9B30FF")
			#if UNITY_ANDROID
			.AddExtra("appid", "com.addictinggames.stfu")
				#elif UNITY_IPHONE
				.AddExtra("appid", "1004032534")
				#endif
				.Build();
		
	}
	
	public void ShowInterstitial()
	{
		moreAG.SetActive(false);
		if (interstitial != null && loaded)
		{
			interstitial.Show();
		}
		else
		{
			RequestInterstitial();
			print("Interstitial is not ready yet.");
		}
	}
	
	#region Interstitial callback handlers
	
	public void HandleInterstitialLoaded(object sender, EventArgs args)
	{
		loaded = true;
		if(moreAG != null)
		{
			moreAG.SetActive(true);
		}
		print("HandleInterstitialLoaded event received.");
	}
	
	public void HandleInterstitialFailedToLoad(object sender, AdFailedToLoadEventArgs args)
	{
		loaded = false;
		print("HandleInterstitialFailedToLoad event received with message: " + args.Message);
	}
	
	public void HandleInterstitialOpened(object sender, EventArgs args)
	{
		loaded = false;
		print("HandleInterstitialOpened event received");
	}
	
	void HandleInterstitialClosing(object sender, EventArgs args)
	{
		loaded = false;
		print("HandleInterstitialClosing event received");
	}
	
	public void HandleInterstitialClosed(object sender, EventArgs args)
	{
		print("HandleInterstitialClosed event received");
		loaded = false;
		RequestInterstitial();
	}
	
	public void HandleInterstitialLeftApplication(object sender, EventArgs args)
	{
		print("HandleInterstitialLeftApplication event received");
	}
	
	#endregion
}
