# apk生成脚本
# 参考 https://amorypepelu.github.io/2016/02/10/bash-Compile-Android/


timeSite := http://timestamp.digicert.com
# 库文件
sdklibJar := d:\Android\sdklib.jar
androidJar := d:\android\sdk\platforms\android-27\android.jar

outPath := bin

packageName := com\example\testndk1
activityName :=
APP_ABI := armeabi-v7a
LOCAL_MODULE := myApp#应用名

# 源文件
resFiles := $(wildcard res/drawable-hdpi/*.* res/drawable-ldpi/*.* res/drawable-mdpi/*.* res/layout/*.* res/values/*.*)
assetsFiles :=
srcFiles :=
jniFiles := $(wildcard jni/*.c jni/*.cpp)

# 生成文件
rjavaFile := $(outPath)\$(packageName)\R.java
dexFile := $(outPath)\classes.dex
soFile := libs\$(APP_ABI)\lib$(LOCAL_MODULE).so
resourcePack := $(outPath)\resources.ap_
appPack := $(outPath)\app.ap_
appApk := $(outPath)\app.apk

# 密钥文件
keystorePass := 123456
keystoreName := jgbDebug
keystoreFile := d:\Android\$(keystoreName).keystore

idYellow := [40;93m
idGreen := [40;92m
idEnd := [0m

#buildMAR buildRjava buildDex buildSo buildKeystore
build: $(appApk) 
	@echo .
	@echo $(idYellow)---------------------------- build done! ----------------------------$(idEnd)



#生成apk文件: 依赖ap_资源包，dex文件，so文件，keystore密钥文件
$(appApk): $(resourcePack) $(rjavaFile) $(dexFile) $(soFile) $(keystoreFile) 
	@echo .
	@echo $(idGreen)---------------------------- build .apk$(idEnd)
	java -cp $(sdklibJar) com.android.sdklib.build.ApkBuilderMain $(appPack) -v -u -z $(resourcePack) -f $(dexFile) -rf src -nf libs
	@echo .
	@echo $(idGreen)---------------------------- build sign apk$(idEnd)
	jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -tsa $(timeSite) -keystore $(keystoreFile) -storepass $(keystorePass) -keypass $(keystorePass) -signedjar $(appApk) $(appPack) $(keystoreName)



#生成资源包ap_文件: 检查资源是否有更新
$(resourcePack): AndroidManifest.xml $(resFiles) $(assetsFiles)
	@echo .
	@echo $(idGreen)---------------------------- build .ap_$(idEnd)
	aapt package -f -M AndroidManifest.xml -A assets -S res -I $(androidJar) -F $(resourcePack)



#生成R.java文件: 检查res资源
$(rjavaFile): $(resFiles)
	@echo .
	@echo $(idGreen)---------------------------- build R.java$(idEnd)
	aapt package -f -m -J $(outPath) -S res -M AndroidManifest.xml -I $(androidJar)



#生成dex文件: 检查src源码是否有更新
$(dexFile): $(srcFiles)
	@echo .
	@echo $(idGreen)---------------------------- build .class$(idEnd)
	javac -bootclasspath $(androidJar) -d $(outPath) $(rjavaFile) $(srcFiles)
	@echo .
	@echo $(idGreen)---------------------------- build .dex$(idEnd)
	dx --dex --output=$(dexFile) $(outPath)



#生成so文件: 检查jni源码是否有更新
$(soFile): $(jniFiles)
	@echo $(idGreen)---------------------------- build .so$(idEnd)
	@echo $(soFile)
	ndk-build NDK_DEBUG=1



#生成keystore文件: 检查密钥文件是否存在
$(keystoreFile): 
	@echo .
	@echo $(idGreen)---------------------------- build .keystore$(idEnd)
	keytool -genkey -keyalg RSA -validity 3650 -alias $(keystoreName) -keystore $(keystoreFile)



test:
	export PATH=$$PATH;D:\Android\SDK\build-tools\27.0.3\ 
	pathlist