package muku.util
{
   import flash.utils.ByteArray;
   import spine.BlendMode;
   import spine.BoneData;
   import spine.Event;
   import spine.EventData;
   import spine.IkConstraintData;
   import spine.PathConstraintData;
   import spine.PositionMode;
   import spine.RotateMode;
   import spine.SkeletonData;
   import spine.Skin;
   import spine.SlotData;
   import spine.SpacingMode;
   import spine.TransformConstraintData;
   import spine.TransformMode;
   import spine.animation.Animation;
   import spine.animation.AttachmentTimeline;
   import spine.animation.ColorTimeline;
   import spine.animation.CurveTimeline;
   import spine.animation.DeformTimeline;
   import spine.animation.DrawOrderTimeline;
   import spine.animation.EventTimeline;
   import spine.animation.IkConstraintTimeline;
   import spine.animation.PathConstraintMixTimeline;
   import spine.animation.PathConstraintPositionTimeline;
   import spine.animation.PathConstraintSpacingTimeline;
   import spine.animation.RotateTimeline;
   import spine.animation.ScaleTimeline;
   import spine.animation.ShearTimeline;
   import spine.animation.Timeline;
   import spine.animation.TransformConstraintTimeline;
   import spine.animation.TranslateTimeline;
   import spine.attachments.Attachment;
   import spine.attachments.AttachmentLoader;
   import spine.attachments.AttachmentType;
   import spine.attachments.BoundingBoxAttachment;
   import spine.attachments.MeshAttachment;
   import spine.attachments.PathAttachment;
   import spine.attachments.RegionAttachment;
   import spine.attachments.VertexAttachment;
   
   public class SkeletonBinary
   {
      
      public static const BONE_ROTATE:int = 0;
      
      public static const BONE_TRANSLATE:int = 1;
      
      public static const BONE_SCALE:int = 2;
      
      public static const BONE_SHEAR:int = 3;
      
      public static const SLOT_ATTACHMENT:int = 0;
      
      public static const SLOT_COLOR:int = 1;
      
      public static const PATH_POSITION:int = 0;
      
      public static const PATH_SPACING:int = 1;
      
      public static const PATH_MIX:int = 2;
      
      public static const CURVE_LINEAR:int = 0;
      
      public static const CURVE_STEPPED:int = 1;
      
      public static const CURVE_BEZIER:int = 2;
      
      private static const MIN_VERSION:Number = 3.5;
       
      
      private var attachmentLoader:AttachmentLoader;
      
      private var scale:Number = 1.0;
      
      private var linkedMeshes:Vector.<LinkedMesh>;
      
      private var version:Number;
      
      private var nonessential:Boolean;
      
      private var readSkinDataPosition:uint;
      
      private var readBonePosition:uint;
      
      private var readAnimationPosition:uint;
      
      private var skeletonData:SkeletonData;
      
      private var input:DataInput;
      
      public function SkeletonBinary(param1:AttachmentLoader)
      {
         linkedMeshes = new Vector.<LinkedMesh>();
         super();
         if(param1 == null)
         {
            throw new Error("attachmentLoader cannot be null.");
         }
         this.attachmentLoader = param1;
      }
      
      private static function setCurve(param1:CurveTimeline, param2:int, param3:Number, param4:Number, param5:Number, param6:Number) : void
      {
         param1.setCurve(param2,param3,param4,param5,param6);
      }
      
      public function getScale() : Number
      {
         return scale;
      }
      
      public function setScale(param1:Number) : void
      {
         this.scale = param1;
      }
      
      public function setAttachmentLoader(param1:AttachmentLoader) : void
      {
         this.attachmentLoader = param1;
      }
      
      public function readSkinData() : SkeletonData
      {
         var _loc1_:int = 0;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:* = null;
         var _loc3_:SkeletonData = new SkeletonData();
         _loc3_.hash = skeletonData.hash;
         _loc3_.version = skeletonData.version;
         _loc3_.width = skeletonData.width;
         _loc3_.height = skeletonData.height;
         _loc3_.fps = skeletonData.fps;
         _loc3_.imagesPath = skeletonData.imagesPath;
         _loc3_.bones = skeletonData.bones.concat();
         _loc3_.slots = skeletonData.slots.concat();
         _loc3_.ikConstraints = skeletonData.ikConstraints.concat();
         _loc3_.transformConstraints = skeletonData.transformConstraints.concat();
         _loc3_.pathConstraints = skeletonData.pathConstraints.concat();
         input.position = readSkinDataPosition;
         var _loc7_:Skin;
         if((_loc7_ = readSkin(input,"default",nonessential)) != null)
         {
            _loc3_.defaultSkin = _loc7_;
            _loc3_.skins.push(_loc7_);
         }
         _loc5_ = 0;
         _loc8_ = input.readIntAdvance(true);
         while(_loc5_ < _loc8_)
         {
            _loc3_.skins.push(readSkin(input,input.readString(),nonessential));
            _loc5_++;
         }
         _loc3_.events = skeletonData.events.concat();
         _loc3_.animations = skeletonData.animations.concat();
         for each(var _loc9_ in _loc3_.animations)
         {
            for each(var _loc6_ in _loc9_._timelines)
            {
               if(_loc6_ is DeformTimeline)
               {
                  if((_loc4_ = _loc7_.getAttachment(DeformTimeline(_loc6_).slotIndex,DeformTimeline(_loc6_).attachment.name#2)) is VertexAttachment)
                  {
                     DeformTimeline(_loc6_).attachment = VertexAttachment(_loc4_);
                  }
               }
            }
         }
         return _loc3_;
      }
      
      public function readSkeletonData(param1:ByteArray) : SkeletonData
      {
         var _loc2_:int = 0;
         var _loc11_:int = 0;
         var _loc3_:int = 0;
         var _loc15_:int = 0;
         var _loc19_:* = null;
         var _loc4_:* = null;
         var _loc6_:* = null;
         var _loc17_:* = null;
         var _loc7_:* = null;
         var _loc13_:* = null;
         var _loc5_:int = 0;
         var _loc20_:* = null;
         var _loc14_:* = null;
         var _loc21_:* = null;
         var _loc16_:* = null;
         var _loc9_:* = null;
         var _loc8_:* = null;
         var _loc18_:* = null;
         var _loc10_:Number = this.scale;
         skeletonData = new SkeletonData();
         input = new DataInput(param1);
         skeletonData.hash = input.readString();
         if(skeletonData.hash == "")
         {
            skeletonData.hash = null;
         }
         skeletonData.version = input.readString();
         if(skeletonData.version == "")
         {
            skeletonData.version = null;
         }
         skeletonData.width = input.readFloat();
         skeletonData.height = input.readFloat();
         version = parseFloat(skeletonData.version);
         nonessential = input.readBoolean();
         if(nonessential)
         {
            skeletonData.fps = input.readFloat();
            skeletonData.imagesPath = input.readString();
            if(skeletonData.imagesPath == "")
            {
               skeletonData.imagesPath = null;
            }
         }
         readBonePosition = input.position;
         _loc11_ = 0;
         _loc15_ = input.readIntAdvance(true);
         while(_loc11_ < _loc15_)
         {
            _loc19_ = input.readString();
            _loc4_ = _loc11_ == 0 ? null : skeletonData.bones[input.readIntAdvance(true)];
            (_loc6_ = new BoneData(_loc11_,_loc19_,_loc4_)).rotation = input.readFloat();
            _loc6_.x = input.readFloat() * _loc10_;
            _loc6_.y = input.readFloat() * _loc10_;
            _loc6_.scaleX = input.readFloat();
            _loc6_.scaleY = input.readFloat();
            _loc6_.shearX = input.readFloat();
            _loc6_.shearY = input.readFloat();
            _loc6_.length = input.readFloat() * _loc10_;
            _loc6_.transformMode = TransformMode.values[input.readIntAdvance(true)];
            if(nonessential)
            {
               input.readInt();
            }
            skeletonData.bones.push(_loc6_);
            _loc11_++;
         }
         _loc11_ = 0;
         _loc15_ = input.readIntAdvance(true);
         while(_loc11_ < _loc15_)
         {
            _loc17_ = input.readString();
            _loc7_ = skeletonData.bones[input.readIntAdvance(true)];
            _loc13_ = new SlotData(_loc11_,_loc17_,_loc7_);
            input.readInt();
            if(version > 3.5)
            {
               _loc5_ = input.readInt();
            }
            _loc13_.attachmentName = input.readString();
            _loc13_.blendMode = BlendMode.values[input.readIntAdvance(true)];
            skeletonData.slots.push(_loc13_);
            _loc11_++;
         }
         _loc11_ = 0;
         _loc15_ = input.readIntAdvance(true);
         while(_loc11_ < _loc15_)
         {
            (_loc20_ = new IkConstraintData(input.readString())).order = input.readIntAdvance(true);
            _loc2_ = 0;
            _loc3_ = input.readIntAdvance(true);
            while(_loc2_ < _loc3_)
            {
               _loc20_.bones.push(skeletonData.bones[input.readIntAdvance(true)]);
               _loc2_++;
            }
            _loc20_.target = skeletonData.bones[input.readIntAdvance(true)];
            _loc20_.mix = input.readFloat();
            _loc20_.bendDirection = input.readByte();
            skeletonData.ikConstraints.push(_loc20_);
            _loc11_++;
         }
         _loc11_ = 0;
         _loc15_ = input.readIntAdvance(true);
         while(_loc11_ < _loc15_)
         {
            (_loc14_ = new TransformConstraintData(input.readString())).order = input.readIntAdvance(true);
            _loc2_ = 0;
            _loc3_ = input.readIntAdvance(true);
            while(_loc2_ < _loc3_)
            {
               _loc14_.bones.push(skeletonData.bones[input.readIntAdvance(true)]);
               _loc2_++;
            }
            _loc14_.target = skeletonData.bones[input.readIntAdvance(true)];
            _loc14_.offsetRotation = input.readFloat();
            _loc14_.offsetX = input.readFloat() * _loc10_;
            _loc14_.offsetY = input.readFloat() * _loc10_;
            _loc14_.offsetScaleX = input.readFloat();
            _loc14_.offsetScaleY = input.readFloat();
            _loc14_.offsetShearY = input.readFloat();
            _loc14_.rotateMix = input.readFloat();
            _loc14_.translateMix = input.readFloat();
            _loc14_.scaleMix = input.readFloat();
            _loc14_.shearMix = input.readFloat();
            skeletonData.transformConstraints.push(_loc14_);
            _loc11_++;
         }
         _loc11_ = 0;
         _loc15_ = input.readIntAdvance(true);
         while(_loc11_ < _loc15_)
         {
            (_loc21_ = new PathConstraintData(input.readString())).order = input.readIntAdvance(true);
            _loc2_ = 0;
            _loc3_ = input.readIntAdvance(true);
            while(_loc2_ < _loc3_)
            {
               _loc21_.bones.push(skeletonData.bones[input.readIntAdvance(true)]);
               _loc2_++;
            }
            _loc21_.target = skeletonData.slots[input.readIntAdvance(true)];
            _loc21_.positionMode = PositionMode.values[input.readIntAdvance(true)];
            _loc21_.spacingMode = SpacingMode.values[input.readIntAdvance(true)];
            _loc21_.rotateMode = RotateMode.values[input.readIntAdvance(true)];
            _loc21_.offsetRotation = input.readFloat();
            _loc21_.position = input.readFloat();
            if(_loc21_.positionMode == PositionMode.fixed)
            {
               _loc21_.position *= _loc10_;
            }
            _loc21_.spacing = input.readFloat();
            if(_loc21_.spacingMode == SpacingMode.length || _loc21_.spacingMode == SpacingMode.fixed)
            {
               _loc21_.spacing *= _loc10_;
            }
            _loc21_.rotateMix = input.readFloat();
            _loc21_.translateMix = input.readFloat();
            skeletonData.pathConstraints.push(_loc21_);
            _loc11_++;
         }
         readSkinDataPosition = input.position;
         var _loc12_:Skin;
         if((_loc12_ = readSkin(input,"default",nonessential)) != null)
         {
            skeletonData.defaultSkin = _loc12_;
            skeletonData.skins.push(_loc12_);
         }
         _loc11_ = 0;
         _loc15_ = input.readIntAdvance(true);
         while(_loc11_ < _loc15_)
         {
            skeletonData.skins.push(readSkin(input,input.readString(),nonessential));
            _loc11_++;
         }
         _loc11_ = 0;
         _loc15_ = linkedMeshes.length;
         while(_loc11_ < _loc15_)
         {
            if((_loc9_ = (_loc16_ = linkedMeshes[_loc11_]).skin == null ? skeletonData.defaultSkin : skeletonData.findSkin(_loc16_.skin)) == null)
            {
               throw new Error("Skin not found: " + _loc16_.skin);
            }
            if((_loc8_ = _loc9_.getAttachment(_loc16_.slotIndex,_loc16_.parent)) == null)
            {
               throw new Error("Parent mesh not found: " + _loc16_.parent);
            }
            _loc16_.mesh.setParentMesh(_loc4_ as MeshAttachment);
            _loc16_.mesh.updateUVs();
            _loc11_++;
         }
         linkedMeshes.length = 0;
         _loc11_ = 0;
         _loc15_ = input.readIntAdvance(true);
         while(_loc11_ < _loc15_)
         {
            (_loc18_ = new EventData(input.readString())).intValue = input.readIntAdvance(false);
            _loc18_.floatValue = input.readFloat();
            _loc18_.stringValue = input.readString();
            skeletonData.events.push(_loc18_);
            _loc11_++;
         }
         readAnimationPosition = input.position;
         _loc11_ = 0;
         _loc15_ = input.readIntAdvance(true);
         while(_loc11_ < _loc15_)
         {
            readAnimation(input.readString(),input,skeletonData);
            _loc11_++;
         }
         return skeletonData;
      }
      
      private function readSkin(param1:DataInput, param2:String, param3:Boolean) : Skin
      {
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc9_:* = null;
         var _loc6_:* = null;
         var _loc7_:int;
         if((_loc7_ = param1.readIntAdvance(true)) == 0)
         {
            return null;
         }
         var _loc8_:Skin = new Skin(param2);
         _loc10_ = 0;
         while(_loc10_ < _loc7_)
         {
            _loc11_ = param1.readIntAdvance(true);
            _loc4_ = 0;
            _loc5_ = param1.readIntAdvance(true);
            while(_loc4_ < _loc5_)
            {
               _loc9_ = param1.readString();
               if((_loc6_ = readAttachment(param1,_loc8_,_loc11_,_loc9_,param3)) != null)
               {
                  _loc8_.addAttachment(_loc11_,_loc9_,_loc6_);
               }
               _loc4_++;
            }
            _loc10_++;
         }
         return _loc8_;
      }
      
      private function readAttachment(param1:DataInput, param2:Skin, param3:int, param4:String, param5:Boolean) : Attachment
      {
         var _loc16_:* = null;
         var _loc7_:int = 0;
         var _loc25_:int = 0;
         var _loc8_:* = null;
         var _loc18_:* = NaN;
         var _loc31_:* = NaN;
         var _loc20_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc35_:* = null;
         var _loc11_:* = null;
         var _loc27_:* = undefined;
         var _loc14_:* = undefined;
         var _loc36_:int = 0;
         var _loc21_:* = undefined;
         var _loc19_:* = null;
         var _loc22_:* = null;
         var _loc6_:* = null;
         var _loc9_:Boolean = false;
         var _loc15_:* = null;
         var _loc34_:Boolean = false;
         var _loc24_:Boolean = false;
         var _loc28_:* = undefined;
         var _loc23_:int = 0;
         var _loc26_:int = 0;
         var _loc29_:* = null;
         var _loc10_:Number = this.scale;
         var _loc30_:*;
         if((_loc30_ = param1.readString()) == null)
         {
            _loc30_ = param4;
         }
         var _loc12_:AttachmentType;
         switch(_loc12_ = AttachmentType.values[param1.readByte()])
         {
            case AttachmentType.region:
               _loc16_ = param1.readString();
               _loc20_ = param1.readFloat();
               _loc32_ = param1.readFloat();
               _loc33_ = param1.readFloat();
               _loc13_ = param1.readFloat();
               _loc17_ = param1.readFloat();
               _loc31_ = Number(param1.readFloat());
               _loc18_ = Number(param1.readFloat());
               _loc7_ = param1.readInt();
               if(_loc16_ == null)
               {
                  _loc16_ = _loc30_;
               }
               if((_loc35_ = attachmentLoader.newRegionAttachment(param2,_loc30_,_loc16_)) == null)
               {
                  return null;
               }
               _loc35_.path = _loc16_;
               _loc35_.x = _loc32_ * _loc10_;
               _loc35_.y = _loc33_ * _loc10_;
               _loc35_.scaleX = _loc13_;
               _loc35_.scaleY = _loc17_;
               _loc35_.rotation = _loc20_;
               _loc35_.width = _loc31_ * _loc10_;
               _loc35_.height = _loc18_ * _loc10_;
               _loc35_.r = toColor(_loc7_,0);
               _loc35_.g = toColor(_loc7_,1);
               _loc35_.b = toColor(_loc7_,2);
               _loc35_.a = toColor(_loc7_,3);
               _loc35_.updateOffset();
               return _loc35_;
               break;
            case AttachmentType.boundingbox:
               _loc25_ = param1.readIntAdvance(true);
               _loc8_ = readVertices(param1,_loc25_);
               _loc7_ = !!param5 ? param1.readInt() : 0;
               if((_loc11_ = attachmentLoader.newBoundingBoxAttachment(param2,_loc30_)) == null)
               {
                  return null;
               }
               _loc11_.worldVerticesLength = _loc25_ << 1;
               _loc11_.vertices = _loc8_.vertices;
               _loc11_.bones = _loc8_.bones;
               if(!param5)
               {
               }
               return _loc11_;
               break;
            case AttachmentType.mesh:
               _loc16_ = param1.readString();
               _loc7_ = param1.readInt();
               _loc25_ = param1.readIntAdvance(true);
               _loc27_ = readFloatArray(param1,_loc25_ << 1,1);
               _loc14_ = readUintArray(param1);
               _loc8_ = readVertices(param1,_loc25_);
               _loc36_ = param1.readIntAdvance(true);
               _loc21_ = null;
               _loc31_ = 0;
               _loc18_ = 0;
               if(param5)
               {
                  _loc21_ = readShortArray(param1);
                  _loc31_ = Number(param1.readFloat());
                  _loc18_ = Number(param1.readFloat());
               }
               if(_loc16_ == null)
               {
                  _loc16_ = _loc30_;
               }
               if((_loc19_ = attachmentLoader.newMeshAttachment(param2,_loc30_,_loc16_)) == null)
               {
                  return null;
               }
               _loc19_.path = _loc16_;
               _loc19_.r = toColor(_loc7_,0);
               _loc19_.g = toColor(_loc7_,1);
               _loc19_.b = toColor(_loc7_,2);
               _loc19_.a = toColor(_loc7_,3);
               _loc19_.bones = _loc8_.bones;
               _loc19_.vertices = _loc8_.vertices;
               _loc19_.worldVerticesLength = _loc25_ << 1;
               _loc19_.triangles = _loc14_;
               _loc19_.regionUVs = _loc27_;
               _loc19_.updateUVs();
               _loc19_.hullLength = _loc36_ << 1;
               if(param5)
               {
                  _loc19_.edges = _loc21_;
                  _loc19_.width = _loc31_ * _loc10_;
                  _loc19_.height = _loc18_ * _loc10_;
               }
               return _loc19_;
               break;
            case AttachmentType.linkedmesh:
               _loc16_ = param1.readString();
               _loc7_ = param1.readInt();
               _loc22_ = param1.readString();
               _loc6_ = param1.readString();
               _loc9_ = param1.readBoolean();
               _loc31_ = 0;
               _loc18_ = 0;
               if(param5)
               {
                  _loc31_ = Number(param1.readFloat());
                  _loc18_ = Number(param1.readFloat());
               }
               if(_loc16_ == null)
               {
                  _loc16_ = _loc30_;
               }
               if((_loc15_ = attachmentLoader.newMeshAttachment(param2,_loc30_,_loc16_)) == null)
               {
                  return null;
               }
               _loc15_.path = _loc16_;
               _loc15_.r = toColor(_loc7_,0);
               _loc15_.g = toColor(_loc7_,1);
               _loc15_.b = toColor(_loc7_,2);
               _loc15_.a = toColor(_loc7_,3);
               _loc15_.inheritDeform = _loc9_;
               if(param5)
               {
                  _loc15_.width = _loc31_ * _loc10_;
                  _loc15_.height = _loc18_ * _loc10_;
               }
               linkedMeshes.push(new LinkedMesh(_loc15_,_loc22_,param3,_loc6_));
               return _loc15_;
               break;
            case AttachmentType.path:
               _loc34_ = param1.readBoolean();
               _loc24_ = param1.readBoolean();
               _loc25_ = param1.readIntAdvance(true);
               _loc8_ = readVertices(param1,_loc25_);
               _loc28_ = new Vector.<Number>(_loc25_ / 3);
               _loc23_ = 0;
               _loc26_ = _loc28_.length;
               while(_loc23_ < _loc26_)
               {
                  _loc28_[_loc23_] = param1.readFloat() * _loc10_;
                  _loc23_++;
               }
               _loc7_ = !!param5 ? param1.readInt() : 0;
               if((_loc29_ = attachmentLoader.newPathAttachment(param2,_loc30_)) == null)
               {
                  return null;
               }
               _loc29_.closed = _loc34_;
               _loc29_.constantSpeed = _loc24_;
               _loc29_.worldVerticesLength = _loc25_ << 1;
               _loc29_.vertices = _loc8_.vertices;
               _loc29_.bones = _loc8_.bones;
               _loc29_.lengths = _loc28_;
               if(param5)
               {
                  _loc29_.r = toColor(_loc7_,0);
                  _loc29_.g = toColor(_loc7_,1);
                  _loc29_.b = toColor(_loc7_,2);
                  _loc29_.a = toColor(_loc7_,3);
               }
               return _loc29_;
               break;
            default:
               return null;
         }
      }
      
      private function readAnimation(param1:String, param2:DataInput, param3:SkeletonData) : void
      {
         var _loc9_:int = 0;
         var _loc45_:int = 0;
         var _loc24_:int = 0;
         var _loc47_:int = 0;
         var _loc25_:int = 0;
         var _loc48_:int = 0;
         var _loc49_:int = 0;
         var _loc13_:int = 0;
         var _loc53_:Number = NaN;
         var _loc33_:int = 0;
         var _loc41_:* = NaN;
         var _loc35_:* = null;
         var _loc26_:int = 0;
         var _loc51_:* = null;
         var _loc21_:int = 0;
         var _loc12_:* = null;
         var _loc4_:* = null;
         var _loc27_:* = null;
         var _loc46_:* = null;
         var _loc22_:* = null;
         var _loc5_:* = null;
         var _loc10_:* = null;
         var _loc30_:* = null;
         var _loc31_:int = 0;
         var _loc14_:int = 0;
         var _loc42_:* = null;
         var _loc8_:* = false;
         var _loc28_:* = undefined;
         var _loc29_:int = 0;
         var _loc7_:* = null;
         var _loc11_:* = undefined;
         var _loc38_:int = 0;
         var _loc43_:int = 0;
         var _loc19_:int = 0;
         var _loc50_:* = 0;
         var _loc15_:int = 0;
         var _loc20_:* = null;
         var _loc36_:int = 0;
         var _loc23_:int = 0;
         var _loc18_:* = undefined;
         var _loc44_:* = undefined;
         var _loc37_:int = 0;
         var _loc6_:int = 0;
         var _loc52_:* = null;
         var _loc17_:* = null;
         var _loc40_:* = null;
         var _loc16_:Vector.<Timeline> = new Vector.<Timeline>();
         var _loc32_:Number = this.scale;
         var _loc34_:* = 0;
         try
         {
            _loc45_ = 0;
            _loc47_ = param2.readIntAdvance(true);
            while(_loc45_ < _loc47_)
            {
               _loc33_ = param2.readIntAdvance(true);
               _loc9_ = 0;
               _loc24_ = param2.readIntAdvance(true);
               while(_loc9_ < _loc24_)
               {
                  _loc48_ = param2.readByte();
                  _loc49_ = param2.readIntAdvance(true);
                  switch(int(_loc48_))
                  {
                     case 0:
                        (_loc51_ = new AttachmentTimeline(_loc49_)).slotIndex = _loc33_;
                        _loc25_ = 0;
                        while(_loc25_ < _loc49_)
                        {
                           _loc51_.setFrame(_loc25_,param2.readFloat(),param2.readString());
                           _loc25_++;
                        }
                        _loc16_.push(_loc51_);
                        _loc34_ = Number(Math.max(_loc34_,_loc51_.frames[_loc49_ - 1]));
                        break;
                     case 1:
                        (_loc35_ = new ColorTimeline(_loc49_)).slotIndex = _loc33_;
                        _loc25_ = 0;
                        while(_loc25_ < _loc49_)
                        {
                           _loc53_ = param2.readFloat();
                           _loc26_ = param2.readInt();
                           _loc35_.setFrame(_loc25_,_loc53_,toColor(_loc26_,0),toColor(_loc26_,1),toColor(_loc26_,2),toColor(_loc26_,3));
                           if(_loc25_ < _loc49_ - 1)
                           {
                              readCurve(param2,_loc25_,_loc35_);
                           }
                           _loc25_++;
                        }
                        _loc16_.push(_loc35_);
                        _loc34_ = Number(Math.max(_loc34_,_loc35_.frames[(_loc49_ - 1) * 5]));
                        break;
                  }
                  _loc9_++;
               }
               _loc45_++;
            }
            _loc45_ = 0;
            _loc47_ = param2.readIntAdvance(true);
            while(_loc45_ < _loc47_)
            {
               _loc21_ = param2.readIntAdvance(true);
               _loc9_ = 0;
               _loc24_ = param2.readIntAdvance(true);
               while(_loc9_ < _loc24_)
               {
                  _loc48_ = param2.readByte();
                  _loc49_ = param2.readIntAdvance(true);
                  switch(int(_loc48_))
                  {
                     case 0:
                        (_loc12_ = new RotateTimeline(_loc49_)).boneIndex = _loc21_;
                        _loc25_ = 0;
                        while(_loc25_ < _loc49_)
                        {
                           _loc12_.setFrame(_loc25_,param2.readFloat(),param2.readFloat());
                           if(_loc25_ < _loc49_ - 1)
                           {
                              readCurve(param2,_loc25_,_loc12_);
                           }
                           _loc25_++;
                        }
                        _loc16_.push(_loc12_);
                        _loc34_ = Number(Math.max(_loc34_,_loc12_.frames[(_loc49_ - 1) * 2]));
                        break;
                     case 1:
                     case 2:
                     case 3:
                        _loc41_ = 1;
                        if(_loc48_ == 2)
                        {
                           _loc4_ = new ScaleTimeline(_loc49_);
                        }
                        else if(_loc48_ == 3)
                        {
                           _loc4_ = new ShearTimeline(_loc49_);
                        }
                        else
                        {
                           _loc4_ = new TranslateTimeline(_loc49_);
                           _loc41_ = _loc32_;
                        }
                        _loc4_.boneIndex = _loc21_;
                        _loc25_ = 0;
                        while(_loc25_ < _loc49_)
                        {
                           _loc4_.setFrame(_loc25_,param2.readFloat(),param2.readFloat() * _loc41_,param2.readFloat() * _loc41_);
                           if(_loc25_ < _loc49_ - 1)
                           {
                              readCurve(param2,_loc25_,_loc4_);
                           }
                           _loc25_++;
                        }
                        _loc16_.push(_loc4_);
                        _loc34_ = Number(Math.max(_loc34_,_loc4_.frames[(_loc49_ - 1) * 3]));
                        break;
                  }
                  _loc9_++;
               }
               _loc45_++;
            }
            _loc45_ = 0;
            _loc47_ = param2.readIntAdvance(true);
            while(_loc45_ < _loc47_)
            {
               _loc13_ = param2.readIntAdvance(true);
               _loc49_ = param2.readIntAdvance(true);
               (_loc27_ = new IkConstraintTimeline(_loc49_)).ikConstraintIndex = _loc13_;
               _loc25_ = 0;
               while(_loc25_ < _loc49_)
               {
                  _loc27_.setFrame(_loc25_,param2.readFloat(),param2.readFloat(),param2.readByte());
                  if(_loc25_ < _loc49_ - 1)
                  {
                     readCurve(param2,_loc25_,_loc27_);
                  }
                  _loc25_++;
               }
               _loc16_.push(_loc27_);
               _loc34_ = Number(Math.max(_loc34_,_loc27_.frames[(_loc49_ - 1) * 3]));
               _loc45_++;
            }
            _loc45_ = 0;
            _loc47_ = param2.readIntAdvance(true);
            while(_loc45_ < _loc47_)
            {
               _loc13_ = param2.readIntAdvance(true);
               _loc49_ = param2.readIntAdvance(true);
               (_loc46_ = new TransformConstraintTimeline(_loc49_)).transformConstraintIndex = _loc13_;
               _loc25_ = 0;
               while(_loc25_ < _loc49_)
               {
                  _loc46_.setFrame(_loc25_,param2.readFloat(),param2.readFloat(),param2.readFloat(),param2.readFloat(),param2.readFloat());
                  if(_loc25_ < _loc49_ - 1)
                  {
                     readCurve(param2,_loc25_,_loc46_);
                  }
                  _loc25_++;
               }
               _loc16_.push(_loc46_);
               _loc34_ = Number(Math.max(_loc34_,_loc46_.frames[(_loc49_ - 1) * 5]));
               _loc45_++;
            }
            _loc45_ = 0;
            _loc47_ = param2.readIntAdvance(true);
            while(_loc45_ < _loc47_)
            {
               _loc13_ = param2.readIntAdvance(true);
               _loc22_ = param3.pathConstraints[_loc13_];
               _loc9_ = 0;
               _loc24_ = param2.readIntAdvance(true);
               while(_loc9_ < _loc24_)
               {
                  _loc48_ = param2.readByte();
                  _loc49_ = param2.readIntAdvance(true);
                  switch(int(_loc48_))
                  {
                     case 0:
                     case 1:
                        _loc41_ = 1;
                        if(_loc48_ == 1)
                        {
                           _loc5_ = new PathConstraintSpacingTimeline(_loc49_);
                           if(_loc22_.spacingMode == SpacingMode.length || _loc22_.spacingMode == SpacingMode.fixed)
                           {
                              _loc41_ = _loc32_;
                           }
                        }
                        else
                        {
                           _loc5_ = new PathConstraintPositionTimeline(_loc49_);
                           if(_loc22_.positionMode == PositionMode.fixed)
                           {
                              _loc41_ = _loc32_;
                           }
                        }
                        _loc5_.pathConstraintIndex = _loc13_;
                        _loc25_ = 0;
                        while(_loc25_ < _loc49_)
                        {
                           _loc5_.setFrame(_loc25_,param2.readFloat(),param2.readFloat() * _loc41_);
                           if(_loc25_ < _loc49_ - 1)
                           {
                              readCurve(param2,_loc25_,_loc5_);
                           }
                           _loc25_++;
                        }
                        _loc16_.push(_loc5_);
                        _loc34_ = Number(Math.max(_loc34_,_loc5_.frames[(_loc49_ - 1) * 2]));
                        break;
                     case 2:
                        (_loc10_ = new PathConstraintMixTimeline(_loc49_)).pathConstraintIndex = _loc13_;
                        _loc25_ = 0;
                        while(_loc25_ < _loc49_)
                        {
                           _loc10_.setFrame(_loc25_,param2.readFloat(),param2.readFloat(),param2.readFloat());
                           if(_loc25_ < _loc49_ - 1)
                           {
                              readCurve(param2,_loc25_,_loc10_);
                           }
                           _loc25_++;
                        }
                        _loc16_.push(_loc10_);
                        _loc34_ = Number(Math.max(_loc34_,_loc10_.frames[(_loc49_ - 1) * 3]));
                        break;
                  }
                  _loc9_++;
               }
               _loc45_++;
            }
            _loc45_ = 0;
            _loc47_ = param2.readIntAdvance(true);
            while(_loc45_ < _loc47_)
            {
               _loc30_ = param3.skins[param2.readIntAdvance(true)];
               _loc9_ = 0;
               _loc24_ = param2.readIntAdvance(true);
               while(_loc9_ < _loc24_)
               {
                  _loc33_ = param2.readIntAdvance(true);
                  _loc31_ = 0;
                  _loc14_ = param2.readIntAdvance(true);
                  while(_loc31_ < _loc14_)
                  {
                     _loc8_ = (_loc42_ = _loc30_.getAttachment(_loc33_,param2.readString()) as VertexAttachment).bones != null;
                     _loc28_ = _loc42_.vertices;
                     _loc29_ = !!_loc8_ ? _loc28_.length / 3 * 2 : _loc28_.length;
                     _loc49_ = param2.readIntAdvance(true);
                     (_loc7_ = new DeformTimeline(_loc49_)).slotIndex = _loc33_;
                     _loc7_.attachment = _loc42_;
                     _loc25_ = 0;
                     while(_loc25_ < _loc49_)
                     {
                        _loc53_ = param2.readFloat();
                        if((_loc38_ = param2.readIntAdvance(true)) == 0)
                        {
                           _loc11_ = !!_loc8_ ? new Vector.<Number>(_loc29_) : _loc28_;
                        }
                        else
                        {
                           _loc11_ = new Vector.<Number>(_loc29_);
                           _loc43_ = param2.readIntAdvance(true);
                           _loc38_ += _loc43_;
                           if(_loc32_ == 1)
                           {
                              _loc50_ = _loc43_;
                              while(_loc50_ < _loc38_)
                              {
                                 _loc11_[_loc50_] = param2.readFloat();
                                 _loc50_++;
                              }
                           }
                           else
                           {
                              _loc50_ = _loc43_;
                              while(_loc50_ < _loc38_)
                              {
                                 _loc11_[_loc50_] = param2.readFloat() * _loc32_;
                                 _loc50_++;
                              }
                           }
                           if(!_loc8_)
                           {
                              _loc50_ = 0;
                              _loc19_ = _loc11_.length;
                              while(_loc50_ < _loc19_)
                              {
                                 var _loc55_:* = _loc50_;
                                 var _loc56_:* = _loc11_[_loc55_] + _loc28_[_loc50_];
                                 _loc11_[_loc55_] = _loc56_;
                                 _loc50_++;
                              }
                           }
                        }
                        _loc7_.setFrame(_loc25_,_loc53_,_loc11_);
                        if(_loc25_ < _loc49_ - 1)
                        {
                           readCurve(param2,_loc25_,_loc7_);
                        }
                        _loc25_++;
                     }
                     _loc16_.push(_loc7_);
                     _loc34_ = Number(Math.max(_loc34_,_loc7_.frames[_loc49_ - 1]));
                     _loc31_++;
                  }
                  _loc9_++;
               }
               _loc45_++;
            }
            if((_loc15_ = param2.readIntAdvance(true)) > 0)
            {
               _loc20_ = new DrawOrderTimeline(_loc15_);
               _loc36_ = param3.slots.length;
               _loc45_ = 0;
               while(_loc45_ < _loc15_)
               {
                  _loc53_ = param2.readFloat();
                  _loc23_ = param2.readIntAdvance(true);
                  _loc18_ = new Vector.<int>(_loc36_);
                  _loc9_ = _loc36_ - 1;
                  while(_loc9_ >= 0)
                  {
                     _loc18_[_loc9_] = -1;
                     _loc9_--;
                  }
                  _loc44_ = new Vector.<int>(_loc36_ - _loc23_);
                  _loc37_ = 0;
                  var _loc39_:int = 0;
                  _loc9_ = 0;
                  while(_loc9_ < _loc23_)
                  {
                     _loc33_ = param2.readIntAdvance(true);
                     while(_loc37_ != _loc33_)
                     {
                        _loc44_[_loc39_++] = _loc37_++;
                     }
                     _loc18_[_loc37_ + param2.readIntAdvance(true)] = _loc37_++;
                     _loc9_++;
                  }
                  while(_loc37_ < _loc36_)
                  {
                     _loc44_[_loc39_++] = _loc37_++;
                  }
                  _loc9_ = _loc36_ - 1;
                  while(_loc9_ >= 0)
                  {
                     if(_loc18_[_loc9_] == -1)
                     {
                        _loc39_--;
                        _loc18_[_loc9_] = _loc44_[_loc39_];
                     }
                     _loc9_--;
                  }
                  _loc20_.setFrame(_loc45_,_loc53_,_loc18_);
                  _loc45_++;
               }
               _loc16_.push(_loc20_);
               _loc34_ = Number(Math.max(_loc34_,_loc20_.frames[_loc15_ - 1]));
            }
            if((_loc6_ = param2.readIntAdvance(true)) > 0)
            {
               _loc52_ = new EventTimeline(_loc6_);
               _loc45_ = 0;
               while(_loc45_ < _loc6_)
               {
                  _loc53_ = param2.readFloat();
                  _loc17_ = param3.events[param2.readIntAdvance(true)];
                  (_loc40_ = new Event(_loc53_,_loc17_)).intValue = param2.readIntAdvance(false);
                  _loc40_.floatValue = param2.readFloat();
                  _loc40_.stringValue = !!param2.readBoolean() ? param2.readString() : _loc17_.stringValue;
                  _loc52_.setFrame(_loc45_,_loc40_);
                  _loc45_++;
               }
               _loc16_.push(_loc52_);
               _loc34_ = Number(Math.max(_loc34_,_loc52_.frames[_loc6_ - 1]));
            }
         }
         catch(error:Error)
         {
            throw new Error("Error reading skeleton file. : " + error);
         }
         param3.animations.push(new Animation(param1,_loc16_,_loc34_));
      }
      
      private function readVertices(param1:DataInput, param2:int) : Vertices
      {
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:* = param2 << 1;
         var _loc4_:Vertices = new Vertices();
         if(!param1.readBoolean())
         {
            _loc4_.vertices = readFloatArray(param1,_loc6_,scale);
            return _loc4_;
         }
         var _loc8_:Vector.<Number> = new Vector.<Number>();
         var _loc9_:Vector.<int> = new Vector.<int>();
         _loc5_ = 0;
         while(_loc5_ < param2)
         {
            _loc7_ = param1.readIntAdvance(true);
            _loc9_.push(_loc7_);
            _loc3_ = 0;
            while(_loc3_ < _loc7_)
            {
               _loc9_.push(param1.readIntAdvance(true));
               _loc8_.push(param1.readFloat() * scale);
               _loc8_.push(param1.readFloat() * scale);
               _loc8_.push(param1.readFloat());
               _loc3_++;
            }
            _loc5_++;
         }
         _loc4_.vertices = _loc8_;
         _loc4_.bones = _loc9_;
         return _loc4_;
      }
      
      private function readCurve(param1:DataInput, param2:int, param3:CurveTimeline) : void
      {
         switch(int(param1.readByte()) - 1)
         {
            case 0:
               param3.setStepped(param2);
               break;
            case 1:
               setCurve(param3,param2,param1.readFloat(),param1.readFloat(),param1.readFloat(),param1.readFloat());
         }
      }
      
      private function readFloatArray(param1:DataInput, param2:int, param3:Number) : Vector.<Number>
      {
         var _loc5_:int = 0;
         var _loc4_:Vector.<Number> = new Vector.<Number>(param2);
         if(param3 == 1)
         {
            _loc5_ = 0;
            while(_loc5_ < param2)
            {
               _loc4_[_loc5_] = param1.readFloat();
               _loc5_++;
            }
         }
         else
         {
            _loc5_ = 0;
            while(_loc5_ < param2)
            {
               _loc4_[_loc5_] = param1.readFloat() * param3;
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      private function readShortArray(param1:DataInput) : Vector.<int>
      {
         var _loc3_:int = 0;
         var _loc4_:int = param1.readIntAdvance(true);
         var _loc2_:Vector.<int> = new Vector.<int>(_loc4_);
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc2_[_loc3_] = param1.readShort();
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function readUintArray(param1:DataInput) : Vector.<uint>
      {
         var _loc3_:int = 0;
         var _loc4_:int = param1.readIntAdvance(true);
         var _loc2_:Vector.<uint> = new Vector.<uint>(_loc4_);
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc2_[_loc3_] = param1.readShort();
            _loc3_++;
         }
         return _loc2_;
      }
      
      private function toColor(param1:int, param2:int) : Number
      {
         if(param2 == 0)
         {
            return ((param1 & 4278190080) >>> 24) / 255;
         }
         if(param2 == 1)
         {
            return ((param1 & 16711680) >>> 16) / 255;
         }
         if(param2 == 2)
         {
            return ((param1 & 65280) >>> 8) / 255;
         }
         return (param1 & 255) / 255;
      }
   }
}

import flash.utils.ByteArray;

class DataInput extends ByteArray
{
    
   
   private var chars:ByteArray;
   
   function DataInput(param1:ByteArray)
   {
      chars = new ByteArray();
      super();
      writeBytes(param1);
      position = 0;
      chars.length = 32;
   }
   
   public function readIntAdvance(param1:Boolean) : int
   {
      var _loc3_:int = readByte();
      var _loc2_:* = _loc3_ & 127;
      if((_loc3_ & 128) != 0)
      {
         _loc3_ = readByte();
         _loc2_ |= (_loc3_ & 127) << 7;
         if((_loc3_ & 128) != 0)
         {
            _loc3_ = readByte();
            _loc2_ |= (_loc3_ & 127) << 14;
            if((_loc3_ & 128) != 0)
            {
               _loc3_ = readByte();
               _loc2_ |= (_loc3_ & 127) << 21;
               if((_loc3_ & 128) != 0)
               {
                  _loc3_ = readByte();
                  _loc2_ |= (_loc3_ & 127) << 28;
               }
            }
         }
      }
      return !!param1 ? _loc2_ : _loc2_ >>> 1 ^ -(_loc2_ & 1);
   }
   
   public function readString() : String
   {
      var _loc4_:int = 0;
      var _loc1_:int = 0;
      var _loc3_:int = readIntAdvance(true);
      switch(int(_loc3_))
      {
         case 0:
            return null;
         case 1:
            return "";
         default:
            _loc3_--;
            if(chars.length < _loc3_)
            {
               chars = new ByteArray();
            }
            var _loc5_:ByteArray = this.chars;
            var _loc2_:int = 0;
            _loc4_ = 0;
            while(_loc4_ < _loc3_)
            {
               _loc1_ = readByte();
               switch((_loc1_ >> 4) - -1)
               {
                  case 0:
                     throw new Error();
                  case 13:
                  case 14:
                     _loc5_[_loc2_++] = (_loc1_ & 31) << 6 | readByte() & 63;
                     _loc4_ += 2;
                     break;
                  case 15:
                     _loc5_[_loc2_++] = (_loc1_ & 15) << 12 | (readByte() & 63) << 6 | readByte() & 63;
                     _loc4_ += 3;
                     break;
                  default:
                     _loc5_[_loc2_++] = _loc1_;
                     _loc4_++;
                     break;
               }
            }
            _loc5_.position = 0;
            return _loc5_.readUTFBytes(_loc2_);
      }
   }
}

import spine.attachments.MeshAttachment;

class LinkedMesh
{
    
   
   public var parent:String;
   
   public var skin:String;
   
   public var slotIndex:int;
   
   public var mesh:MeshAttachment;
   
   function LinkedMesh(param1:MeshAttachment, param2:String, param3:int, param4:String)
   {
      super();
      this.mesh = param1;
      this.skin = param2;
      this.slotIndex = param3;
      this.parent = param4;
   }
}

class Vertices
{
    
   
   public var bones:Vector.<int>;
   
   public var vertices:Vector.<Number>;
   
   function Vertices()
   {
      super();
   }
}
