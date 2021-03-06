package com.kashibuyi.chaoliuby;

import android.app.Application;

import com.bun.miitmdid.core.JLibrary;
import com.umeng.commonsdk.UMConfigure;
import com.umeng.commonsdk.UMU3DCommonSDK;
import com.umeng.message.IUmengRegisterCallback;
import com.umeng.message.MsgConstant;
import com.umeng.message.PushAgent;
import com.umeng.message.UTrack;
import com.umeng.message.UmengMessageHandler;
import com.umeng.message.UmengNotificationClickHandler;
import com.umeng.message.entity.UMessage;
import com.wxsdk.my.MiitHelper;
import com.wxsdk.my.WeChatController;

import android.app.Notification;
import android.content.Context;
import android.os.Build;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.util.Log;
import android.widget.Toast;

public class UnityApplication extends Application {
    private Handler handler;
    @Override
    protected void attachBaseContext(Context ctx) {
        super.attachBaseContext(ctx);
        try {
            JLibrary.InitEntry(ctx);
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    @Override
    public void onCreate() {
        super.onCreate();

        UMConfigure.init(this, "5b8d0566f29d98698d0000c8", "Umeng", UMConfigure.DEVICE_TYPE_PHONE,
                "d400aaf4eb88701fc988134d876fb861");
        //UMU3DCommonSDK.init(this, "5b8d0566f29d98698d0000c8", "Umeng", UMConfigure.DEVICE_TYPE_PHONE,
        //        "d400aaf4eb88701fc988134d876fb861");
        initUMPush();

        /*if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            Log.i("oaid", "init miit for oaid");
            MiitHelper miitHelper = new MiitHelper(appIdsUpdater);
            miitHelper.getDeviceIds(getApplicationContext());
        }*/

        new MiitHelper().getDeviceIds(this, new MiitHelper.AppIdsUpdater() {
            @Override
            public void OnIdsAvailed(boolean isSupport, String oaid) {
                Log.i("oaid", "new get:" + oaid);
                WeChatController.GetInstance().SaveOAID(oaid);
            }
        });
    }
    /*private MiitHelper.AppIdsUpdater appIdsUpdater = new MiitHelper.AppIdsUpdater() {
        @Override
        public void OnIdsAvalid(@NonNull String ids) {
            Log.i("oaid", "get:" + ids);
            WeChatController.GetInstance().SaveOAID(ids);
        }
    };*/

    private void initUMPush() {
        PushAgent mPushAgent = PushAgent.getInstance(this);
        mPushAgent.register(new IUmengRegisterCallback() {
            @Override
            public void onSuccess(String s) {
                Log.i("my_token", s);
                WeChatController.GetInstance().SavePushDeviceToken(s);
            }

            @Override
            public void onFailure(String s, String s1) {
                Log.i("register failed: ", s + " " + s1);
            }
        });
    }
    private void initUpush() {
        PushAgent mPushAgent = PushAgent.getInstance(this);
        handler = new Handler(getMainLooper());
        mPushAgent.setNotificationPlaySound(MsgConstant.NOTIFICATION_PLAY_SDK_ENABLE);
        UmengMessageHandler messageHandler = new UmengMessageHandler() {
            /**
             * ??????????????????????????????
             */
            @Override
            public void dealWithCustomMessage(final Context context, final UMessage msg) {

                handler.post(new Runnable() {

                    @Override
                    public void run() {
                        // TODO Auto-generated method stub
                        // ??????????????????????????????????????????????????????
                        boolean isClickOrDismissed = true;
                        if (isClickOrDismissed) {
                            //??????????????????????????????
                            UTrack.getInstance(getApplicationContext()).trackMsgClick(msg);
                        } else {
                            //??????????????????????????????
                            UTrack.getInstance(getApplicationContext()).trackMsgDismissed(msg);
                        }
                        Toast.makeText(context, msg.custom, Toast.LENGTH_LONG).show();
                    }
                });
            }

            /**
             * ???????????????????????????????????????
             */
            @Override
            public Notification getNotification(Context context, UMessage msg) {
                switch (msg.builder_id) {
                    case 1:
                        //Notification.Builder builder = new Notification.Builder(context);
                        //RemoteViews myNotificationView = new RemoteViews(context.getPackageName(), R.layout.notification_view);
                        //myNotificationView.setTextViewText(R.id.notification_title, msg.title);
                        //myNotificationView.setTextViewText(R.id.notification_text, msg.text);
                        //myNotificationView.setImageViewBitmap(R.id.notification_large_icon, getLargeIcon(context, msg));
                        //myNotificationView.setImageViewResource(R.id.notification_small_icon, getSmallIconId(context, msg));
                        //builder.setContent(myNotificationView)
                        //    .setSmallIcon(getSmallIconId(context, msg))
                        //    .setTicker(msg.ticker)
                        //    .setAutoCancel(true);
                        //
                        //return builder.getNotification();
                    default:
                        //?????????0???????????????builder_id?????????????????????????????????
                        return super.getNotification(context, msg);
                }
            }
        };
        mPushAgent.setMessageHandler(messageHandler);
        /**
         * ????????????????????????????????????????????????????????????-????????????????????????-???????????????????????????
         * UmengNotificationClickHandler??????BroadcastReceiver??????????????????
         * ???????????????Activity????????????Intent.FLAG_ACTIVITY_NEW_TASK
         * */
        UmengNotificationClickHandler notificationClickHandler = new UmengNotificationClickHandler() {
            @Override
            public void dealWithCustomAction(Context context, UMessage msg) {
                Toast.makeText(context, msg.custom, Toast.LENGTH_LONG).show();
            }
        };
        //??????????????????NotificationHandler???????????????????????????????????????????????????http://bbs.umeng.com/thread-11112-1-1.html
        //CustomNotificationHandler notificationClickHandler = new CustomNotificationHandler();
        mPushAgent.setNotificationClickHandler(notificationClickHandler);

        mPushAgent.register(new IUmengRegisterCallback() {
            @Override
            public void onSuccess(String s) {
                Log.i("my_token", s);
                WeChatController.GetInstance().SavePushDeviceToken(s);
            }

            @Override
            public void onFailure(String s, String s1) {
                Log.i("register failed: ", s + " " + s1);
            }
        });
    }
}
