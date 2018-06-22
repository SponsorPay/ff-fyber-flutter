package com.fyber.flutter.fyber4flutter

import android.content.Intent
import com.fyber.flutter.fyber4flutter.Fyber4FlutterPlugin.Companion.AVAILABLE_REQUEST_CODES
import io.flutter.app.FlutterActivity
import com.fyber.ads.videos.RewardedVideoActivity



/**
 * Created by Lukasz Huculak on 22.06.2018.
 */
open class FyberFlutterActivity : FlutterActivity() {

    internal var onAdShownResult: ((EngagementResults, Int, String?) -> Unit)? = null

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (resultCode == RESULT_OK){
            if (AVAILABLE_REQUEST_CODES.contains(requestCode) ){
                onAdShownResult?.let{
                    val engagementResult = data?.getStringExtra(RewardedVideoActivity
                            .ENGAGEMENT_STATUS)
                    when (engagementResult) {
                        RewardedVideoActivity.REQUEST_STATUS_PARAMETER_FINISHED_VALUE ->
                            // The user watched the entire video and will be rewarded
                            it(EngagementResults.FINISHED, requestCode, null)
                        RewardedVideoActivity.REQUEST_STATUS_PARAMETER_ABORTED_VALUE ->
                            // The user stopped the video early and will not be rewarded
                            it(EngagementResults.ABORTED, requestCode, null)
                        RewardedVideoActivity.REQUEST_STATUS_PARAMETER_ERROR ->
                            // An error occurred while showing the video and the user will not be rewarded
                            it(EngagementResults.ERROR, requestCode, null)
                    }
                }
            }
        }
    }
}

enum class EngagementResults {
    FINISHED,
    ABORTED,
    ERROR
}