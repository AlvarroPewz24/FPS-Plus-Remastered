package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxDestroyUtil;
import openfl.media.Sound;
import openfl.utils.Assets;
import openfl.system.System;

enum ClearingType
{
	CACHED;
	STORED;
	UNUSED;
}

class Paths
{
	public static final extensions:Map<String, String> = ["image" => "png", "audio" => "ogg", "video" => "mp4"];

	private static var assetsCache:Map<String, Map<String, Any>> = [
		"graphics" => [],
		"sounds" => []
	];

	private static var currentTrackedAssets:Map<String, Map<String, Any>> = [
		"graphics" => [],
		"sounds" => []
	];

	private static var trackedAssets:Map<String, Array<String>> = [
		"graphics" => [],
		"sounds" => []
	];

	public static function clearAssets(assets:String = 'none', type:ClearingType):Void
	{
		if (assets == 'graphics')
		{
			if (type != CACHED)
			{
				if (type == STORED)
				{
					@:privateAccess
					for (key in FlxG.bitmap._cache.keys())
					{
						var obj:Null<FlxGraphic> = FlxG.bitmap._cache.get(key);
						if (obj != null && !assetsCache["graphics"].exists(key) && !currentTrackedAssets["graphics"].exists(key))
						{
							if (Assets.cache.hasBitmapData(key))
								Assets.cache.removeBitmapData(key);

							FlxG.bitmap._cache.remove(key);

							if (trackedAssets["graphics"].contains(key))
								trackedAssets["graphics"].remove(key);

							obj = FlxDestroyUtil.destroy(obj);
						}
					}
				}
				else if (type == UNUSED)
				{
					for (key in currentTrackedAssets["graphics"].keys())
					{
						var obj:Null<FlxGraphic> = FlxG.bitmap._cache.get(key);
						if (obj != null && !assetsCache["graphics"].exists(key) && !trackedAssets["graphics"].contains(path))
						{
							if (Assets.cache.hasBitmapData(key))
								Assets.cache.removeBitmapData(key);

							@:privateAccess
							FlxG.bitmap._cache.remove(key);
							currentTrackedAssets["graphics"].remove(key);
							obj = FlxDestroyUtil.destroy(obj);
						}
					}
				}
			}
			else
			{
				@:privateAccess
				for (key in FlxG.bitmap._cache.keys())
				{
					var obj:Null<FlxGraphic> = FlxG.bitmap._cache.get(key);
					if (obj != null && assetsCache["graphics"].exists(key))
					{
						#if desktop
						GPUBitmap.dispose(KEY(key));
						#end

						if (Assets.cache.hasBitmapData(key))
							Assets.cache.removeBitmapData(key);

						FlxG.bitmap._cache.remove(key);

						if (assetsCache["graphics"].exists(key)) // duble check
							assetsCache["graphics"].remove(key);

						obj = FlxDestroyUtil.destroy(obj);
					}
				}
			}
		}
		else if (assets == 'sounds')
		{
			if (type != CACHED)
			{
				if (type == STORED)
				{
					@:privateAccess
					for (key in Assets.cache.getSoundKeys())
					{
						var obj:Sound = Assets.cache.getSound(key);
						if (obj != null && !assetsCache["sounds"].exists(key) && !currentTrackedAssets["sounds"].exists(key))
						{
							Assets.cache.removeSound(key);

							if (trackedAssets["sounds"].contains(key))
								trackedAssets["sounds"].remove(key);

							obj.close();
						}
					}
				}
				else if (type == UNUSED)
				{
					for (key in currentTrackedAssets["sounds"].keys())
					{
						var obj:Sound = Assets.cache.getSound(key);
						if (obj != null && !assetsCache["sounds"].exists(key) && !trackedAssets["sounds"].contains(path))
						{
							if (Assets.cache.hasSound(key))
								Assets.cache.removeSound(key);

							currentTrackedAssets["sounds"].remove(key);
							obj.close();
						}
					}
				}
			}
			else
			{
				for (key in Assets.cache.getSoundKeys())
				{
					var obj:Sound = Assets.cache.getSound(key);
					if (obj != null && assetsCache["sounds"].exists(key))
					{
						Assets.cache.removeSound(key);
						assetsCache["sounds"].remove(key);
						obj.close();
					}
				}
			}
		}
		else if (assets == 'none')
			trace('no assets clearing!');

		if (assets == 'graphics' || assets == 'sounds')
			System.gc();
	}

	inline static public function file(key:String, location:String, extension:String):String
	{
		var path:String = 'assets/$location/$key.$extension';
		return path;
	}

	inline static public function font(key:String, ?extension:String = "ttf"):String
	{
		var path:String = file(key, "fonts", extension);
		return path;
	}

	inline static public function xml(key:String, ?location:String = "data"):String
	{
		var path:String = file(key, location, "xml");
		return path;
	}

	inline static public function text(key:String, ?location:String = "data"):String
	{
		var path:String = file(key, location, "txt");
		return path;
	}

	inline static public function json(key:String, ?location:String = "data"):String
	{
		var path:String = file(key, location, "json");
		return path;
	}

	inline static public function image(key:String, ?location:String = "images"):FlxGraphic
	{
		var path:String = file(key, location, extensions.get("image"));
		return loadImage(path);
	}

	inline static public function sound(key:String, ?location:String = "sounds"):Sound
	{
		var path:String = file(key, location, extensions.get("audio"));
		return loadSound(path);
	}

	inline static public function music(key:String, ?location:String = "music"):Sound
	{
		var path:String = file(key, location, extensions.get("audio"));
		return loadSound(path);
	}

	inline static public function voices(key:String, ?location:String = "songs"):Sound
	{
		var path:String = file('$key/Voices', location, extensions.get("audio"));
		return loadSound(path);
	}

	inline static public function inst(key:String, ?location:String = "songs"):Sound
	{
		var path:String = file('$key/Inst', location, extensions.get("audio"));
		return loadSound(path);
	}

	inline static public function video(key:String, ?location:String = "videos"):String
	{
		var path:String = file(key, location, extensions.get("video"));
		return path;
	}

	inline static public function getSparrowAtlas(key:String, ?location:String = "images"):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key, location), xml(key, location));

	inline static public function getPackerAtlas(key:String, ?location:String = "images"):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, location), text(key, location));

	public static function loadImage(path:String, ?addToCache:Bool = false):FlxGraphic
	{
		if (Assets.exists(path, IMAGE))
		{
			if (addToCache && !assetsCache["graphics"].exists(path))
			{
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(#if desktop GPUBitmap.create(path) #else Assets.getBitmapData(path) #end);
				graphic.persist = true;
				graphic.destroyOnNoUse = false;
				assetsCache["graphics"].set(path, graphic);

				return assetsCache["graphics"].get(path);
			}
			else if (assetsCache["graphics"].exists(path))
			{
				trace('$path is already loaded to the cache!');
				return assetsCache["graphics"].get(path);
			}
			else
			{
				if (!currentTrackedAssets["graphics"].exists(path))
				{
					var graphic:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(path));
					graphic.persist = true;
					graphic.destroyOnNoUse = false;
					currentTrackedAssets["graphics"].set(path, graphic);
				}
				else
					trace('$path is already tracked!');

				if (!trackedAssets["graphics"].contains(path))
					trackedAssets["graphics"].push(path);

				return currentTrackedAssets["graphics"].get(path);
			}
		}
		else
			trace('$path is null!');

		return null;
	}

	public static function loadSound(path:String, ?addToCache:Bool = false):Sound
	{
		if (Assets.exists(path, SOUND))
		{
			if (addToCache && !assetsCache["sounds"].exists(path))
			{
				assetsCache["sounds"].set(path, Assets.getSound(path));
				return assetsCache["sounds"].get(path);
			}
			else if (assetsCache["sounds"].exists(path))
			{
				trace('$path is already loaded to the cache!');
				return assetsCache["sounds"].get(path);
			}
			else
			{
				if (!currentTrackedAssets["sounds"].exists(path))
					currentTrackedAssets["sounds"].set(path, Assets.getSound(path));
				else
					trace('$path is already tracked!');

				if (!trackedAssets["sounds"].contains(path))
					trackedAssets["sounds"].push(path);

				return currentTrackedAssets["sounds"].get(path);
			}
		}
		else
			trace('$path is null!');

		return null;
	}
}
