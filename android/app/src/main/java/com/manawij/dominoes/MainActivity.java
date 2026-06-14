package com.manawij.dominoes;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MainActivity extends Activity {

    private WebView web;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Immersive, edge-to-edge full screen so the game uses the whole display.
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().getDecorView().setSystemUiVisibility(
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN);

        web = new WebView(this);
        setContentView(web);

        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);                 // localStorage (mute / profile)
        s.setMediaPlaybackRequiresUserGesture(true);  // keep audio gated to a tap
        s.setAllowFileAccess(true);
        s.setAllowContentAccess(true);
        s.setCacheMode(WebSettings.LOAD_DEFAULT);
        s.setLoadWithOverviewMode(true);
        s.setUseWideViewPort(true);

        // Keep navigation inside the WebView.
        web.setWebViewClient(new WebViewClient());
        web.setWebChromeClient(new WebChromeClient());

        web.loadUrl("file:///android_asset/dominoes.html");
    }

    // Hand the hardware Back button to the in-page screen logic first. The game is
    // a single HTML page (screens are toggled in JS, no browser history), so
    // canGoBack() is always false and the old code quit the app instantly even
    // mid-game. window.onAndroidBack() closes overlays / returns to the menu and
    // only returns false (→ let the OS exit) when we're already on the main menu.
    @Override
    public void onBackPressed() {
        if (web == null) {
            super.onBackPressed();
            return;
        }
        web.evaluateJavascript(
                "(window.onAndroidBack && window.onAndroidBack()) ? '1' : '0'",
                value -> {
                    if (!"1".equals(value)) {
                        runOnUiThread(() -> MainActivity.super.onBackPressed());
                    }
                });
    }
}
