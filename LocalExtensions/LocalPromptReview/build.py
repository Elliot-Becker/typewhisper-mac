import json
from pathlib import Path
import plistlib
import shutil
import subprocess
import sys

ROOT=Path(__file__).resolve().parent
PRODUCTS=Path(sys.argv[1]).expanduser().resolve() if len(sys.argv)>1 else ROOT.parent/'typewhisper-evaluation/DerivedData/Build/Products/Debug'
BUNDLE=ROOT/'build/LocalPromptReview.bundle'
for part in ['Contents/MacOS','Contents/Resources']: (BUNDLE/part).mkdir(parents=True,exist_ok=True)
manifest=dict(id='local.elliot.prompt-review',name='Local Prompt Review',version='0.1.0',minHostVersion='1.8.2',sdkCompatibilityVersion='v1',minOSVersion='14.0',supportedArchitectures=['arm64'],author='Local evaluation',description='Review original speech and an editable prompt before copying. No automatic insertion, submission, networking, or persistence.',category='action',iconSystemName='doc.text.magnifyingglass',principalClass='LocalPromptReviewPlugin',locality='local')
(BUNDLE/'Contents/Resources/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
with (BUNDLE/'Contents/Info.plist').open('wb') as f:
 plistlib.dump(dict(CFBundleIdentifier=manifest['id'],CFBundleName='Local Prompt Review',CFBundleExecutable='LocalPromptReviewPlugin',CFBundlePackageType='BNDL',CFBundleShortVersionString='0.1.0',CFBundleVersion='1',NSPrincipalClass='LocalPromptReviewPlugin'),f)
subprocess.run(['swiftc','-emit-library','-parse-as-library','-module-name','LocalPromptReviewPlugin','-I',str(PRODUCTS),'-F',str(PRODUCTS/'PackageFrameworks'),'-framework','TypeWhisperPluginSDK',str(ROOT/'LocalPromptReviewPlugin.swift'),str(ROOT/'Sources/ReviewChecks/ReviewChecks.swift'),'-o',str(BUNDLE/'Contents/MacOS/LocalPromptReviewPlugin')],check=True)
subprocess.run(['xattr','-cr',str(BUNDLE)],check=True)
subprocess.run(['codesign','--force','--sign','-',str(BUNDLE)],check=True)
print(BUNDLE)
