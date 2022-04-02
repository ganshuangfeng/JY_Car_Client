--[[
	系统枚举
--]]

Enum = {}

-- DG.Tweening LoopType  Enum

	Enum.LoopType = {}
	
	Enum.LoopType.Restart = 0
	
	Enum.LoopType.Yoyo = 1
	
	Enum.LoopType.Incremental = 2	



-- DG.Tweening PathMode  Enum

	Enum.PathMode = {}
	
	Enum.PathMode.Ignore = 0
	
	Enum.PathMode.Full3D = 1
	
	Enum.PathMode.TopDown2D = 2
	
	Enum.PathMode.Sidescroller2D = 3	



-- DG.Tweening PathType  Enum

	Enum.PathType = {}
	
	Enum.PathType.Linear = 0
	
	Enum.PathType.CatmullRom = 1



-- DG.Tweening RotateMode  Enum

	Enum.RotateMode = {}
	
	Enum.RotateMode.Fast = 0
	
	Enum.RotateMode.FastBeyond360 = 1
	
	Enum.RotateMode.WorldAxisAdd = 2
	
	Enum.RotateMode.LocalAxisAdd = 3	



-- DG.Tweening Ease  Enum

	Enum.Ease = {}
	
	Enum.Ease.Unset = 0
	
	Enum.Ease.Linear = 1
	
	Enum.Ease.InSine = 2
	
	Enum.Ease.OutSine = 3
	
	Enum.Ease.InOutSine = 4
	
	Enum.Ease.InQuad = 5
	
	Enum.Ease.OutQuad = 6
	
	Enum.Ease.InOutQuad = 7
	
	Enum.Ease.InCubic = 8
	
	Enum.Ease.OutCubic = 9
	
	Enum.Ease.InOutCubic = 10
	
	Enum.Ease.InQuart = 11
	
	Enum.Ease.OutQuart = 12
	
	Enum.Ease.InOutQuart = 13
	
	Enum.Ease.InQuint = 14
	
	Enum.Ease.OutQuint = 15
	
	Enum.Ease.InOutQuint = 16
	
	Enum.Ease.InExpo = 17
	
	Enum.Ease.OutExpo = 18
	
	Enum.Ease.InOutExpo = 19
	
	Enum.Ease.InCirc = 20
	
	Enum.Ease.OutCirc = 21
	
	Enum.Ease.InOutCirc = 22
	
	Enum.Ease.InElastic = 23
	
	Enum.Ease.OutElastic = 24
	
	Enum.Ease.InOutElastic = 25
	
	Enum.Ease.InBack = 26
	
	Enum.Ease.OutBack = 27
	
	Enum.Ease.InOutBack = 28
	
	Enum.Ease.InBounce = 29
	
	Enum.Ease.OutBounce = 30
	
	Enum.Ease.InOutBounce = 31
	
	Enum.Ease.Flash = 32
	
	Enum.Ease.InFlash = 33
	
	Enum.Ease.OutFlash = 34
	
	Enum.Ease.InOutFlash = 35
	
	Enum.Ease.INTERNAL_Zero = 36
	
	Enum.Ease.INTERNAL_Custom = 37



-- UnityEngine LightType  Enum

	Enum.LightType = {}
	
	Enum.LightType.Spot = 0
	
	Enum.LightType.Directional = 1
	
	Enum.LightType.Point = 2
	
	Enum.LightType.Area = 3
	
	Enum.LightType.Rectangle = 3
	
	Enum.LightType.Disc = 4



-- UnityEngine KeyCode  Enum

	Enum.KeyCode = {}
	
	Enum.KeyCode.None = 0
	
	Enum.KeyCode.Backspace = 8
	
	Enum.KeyCode.Delete = 127
	
	Enum.KeyCode.Tab = 9
	
	Enum.KeyCode.Clear = 12
	
	Enum.KeyCode.Return = 13
	
	Enum.KeyCode.Pause = 19
	
	Enum.KeyCode.Escape = 27
	
	Enum.KeyCode.Space = 32
	
	Enum.KeyCode.Keypad0 = 256
	
	Enum.KeyCode.Keypad1 = 257
	
	Enum.KeyCode.Keypad2 = 258
	
	Enum.KeyCode.Keypad3 = 259
	
	Enum.KeyCode.Keypad4 = 260
	
	Enum.KeyCode.Keypad5 = 261
	
	Enum.KeyCode.Keypad6 = 262
	
	Enum.KeyCode.Keypad7 = 263
	
	Enum.KeyCode.Keypad8 = 264
	
	Enum.KeyCode.Keypad9 = 265
	
	Enum.KeyCode.KeypadPeriod = 266
	
	Enum.KeyCode.KeypadDivide = 267
	
	Enum.KeyCode.KeypadMultiply = 268
	
	Enum.KeyCode.KeypadMinus = 269
	
	Enum.KeyCode.KeypadPlus = 270
	
	Enum.KeyCode.KeypadEnter = 271
	
	Enum.KeyCode.KeypadEquals = 272
	
	Enum.KeyCode.UpArrow = 273
	
	Enum.KeyCode.DownArrow = 274
	
	Enum.KeyCode.RightArrow = 275
	
	Enum.KeyCode.LeftArrow = 276
	
	Enum.KeyCode.Insert = 277
	
	Enum.KeyCode.Home = 278
	
	Enum.KeyCode.End = 279
	
	Enum.KeyCode.PageUp = 280
	
	Enum.KeyCode.PageDown = 281
	
	Enum.KeyCode.F1 = 282
	
	Enum.KeyCode.F2 = 283
	
	Enum.KeyCode.F3 = 284
	
	Enum.KeyCode.F4 = 285
	
	Enum.KeyCode.F5 = 286
	
	Enum.KeyCode.F6 = 287
	
	Enum.KeyCode.F7 = 288
	
	Enum.KeyCode.F8 = 289
	
	Enum.KeyCode.F9 = 290
	
	Enum.KeyCode.F10 = 291
	
	Enum.KeyCode.F11 = 292
	
	Enum.KeyCode.F12 = 293
	
	Enum.KeyCode.F13 = 294
	
	Enum.KeyCode.F14 = 295
	
	Enum.KeyCode.F15 = 296
	
	Enum.KeyCode.Alpha0 = 48
	
	Enum.KeyCode.Alpha1 = 49
	
	Enum.KeyCode.Alpha2 = 50
	
	Enum.KeyCode.Alpha3 = 51
	
	Enum.KeyCode.Alpha4 = 52
	
	Enum.KeyCode.Alpha5 = 53
	
	Enum.KeyCode.Alpha6 = 54
	
	Enum.KeyCode.Alpha7 = 55
	
	Enum.KeyCode.Alpha8 = 56
	
	Enum.KeyCode.Alpha9 = 57
	
	Enum.KeyCode.Exclaim = 33
	
	Enum.KeyCode.DoubleQuote = 34
	
	Enum.KeyCode.Hash = 35
	
	Enum.KeyCode.Dollar = 36
	
	Enum.KeyCode.Percent = 37
	
	Enum.KeyCode.Ampersand = 38
	
	Enum.KeyCode.Quote = 39
	
	Enum.KeyCode.LeftParen = 40
	
	Enum.KeyCode.RightParen = 41
	
	Enum.KeyCode.Asterisk = 42
	
	Enum.KeyCode.Plus = 43
	
	Enum.KeyCode.Comma = 44
	
	Enum.KeyCode.Minus = 45
	
	Enum.KeyCode.Period = 46
	
	Enum.KeyCode.Slash = 47
	
	Enum.KeyCode.Colon = 58
	
	Enum.KeyCode.Semicolon = 59
	
	Enum.KeyCode.Less = 60
	
	Enum.KeyCode.Equals = 61
	
	Enum.KeyCode.Greater = 62
	
	Enum.KeyCode.Question = 63
	
	Enum.KeyCode.At = 64
	
	Enum.KeyCode.LeftBracket = 91
	
	Enum.KeyCode.Backslash = 92
	
	Enum.KeyCode.RightBracket = 93
	
	Enum.KeyCode.Caret = 94
	
	Enum.KeyCode.Underscore = 95
	
	Enum.KeyCode.BackQuote = 96
	
	Enum.KeyCode.A = 97
	
	Enum.KeyCode.B = 98
	
	Enum.KeyCode.C = 99
	
	Enum.KeyCode.D = 100
	
	Enum.KeyCode.E = 101
	
	Enum.KeyCode.F = 102
	
	Enum.KeyCode.G = 103
	
	Enum.KeyCode.H = 104
	
	Enum.KeyCode.I = 105
	
	Enum.KeyCode.J = 106
	
	Enum.KeyCode.K = 107
	
	Enum.KeyCode.L = 108
	
	Enum.KeyCode.M = 109
	
	Enum.KeyCode.N = 110
	
	Enum.KeyCode.O = 111
	
	Enum.KeyCode.P = 112
	
	Enum.KeyCode.Q = 113
	
	Enum.KeyCode.R = 114
	
	Enum.KeyCode.S = 115
	
	Enum.KeyCode.T = 116
	
	Enum.KeyCode.U = 117
	
	Enum.KeyCode.V = 118
	
	Enum.KeyCode.W = 119
	
	Enum.KeyCode.X = 120
	
	Enum.KeyCode.Y = 121
	
	Enum.KeyCode.Z = 122
	
	Enum.KeyCode.LeftCurlyBracket = 123
	
	Enum.KeyCode.Pipe = 124
	
	Enum.KeyCode.RightCurlyBracket = 125
	
	Enum.KeyCode.Tilde = 126
	
	Enum.KeyCode.Numlock = 300
	
	Enum.KeyCode.CapsLock = 301
	
	Enum.KeyCode.ScrollLock = 302
	
	Enum.KeyCode.RightShift = 303
	
	Enum.KeyCode.LeftShift = 304
	
	Enum.KeyCode.RightControl = 305
	
	Enum.KeyCode.LeftControl = 306
	
	Enum.KeyCode.RightAlt = 307
	
	Enum.KeyCode.LeftAlt = 308
	
	Enum.KeyCode.LeftCommand = 310
	
	Enum.KeyCode.LeftApple = 310
	
	Enum.KeyCode.LeftWindows = 311
	
	Enum.KeyCode.RightCommand = 309
	
	Enum.KeyCode.RightApple = 309
	
	Enum.KeyCode.RightWindows = 312
	
	Enum.KeyCode.AltGr = 313
	
	Enum.KeyCode.Help = 315
	
	Enum.KeyCode.Print = 316
	
	Enum.KeyCode.SysReq = 317
	
	Enum.KeyCode.Break = 318
	
	Enum.KeyCode.Menu = 319
	
	Enum.KeyCode.Mouse0 = 323
	
	Enum.KeyCode.Mouse1 = 324
	
	Enum.KeyCode.Mouse2 = 325
	
	Enum.KeyCode.Mouse3 = 326
	
	Enum.KeyCode.Mouse4 = 327
	
	Enum.KeyCode.Mouse5 = 328
	
	Enum.KeyCode.Mouse6 = 329
	
	Enum.KeyCode.JoystickButton0 = 330
	
	Enum.KeyCode.JoystickButton1 = 331
	
	Enum.KeyCode.JoystickButton2 = 332
	
	Enum.KeyCode.JoystickButton3 = 333
	
	Enum.KeyCode.JoystickButton4 = 334
	
	Enum.KeyCode.JoystickButton5 = 335
	
	Enum.KeyCode.JoystickButton6 = 336
	
	Enum.KeyCode.JoystickButton7 = 337
	
	Enum.KeyCode.JoystickButton8 = 338
	
	Enum.KeyCode.JoystickButton9 = 339
	
	Enum.KeyCode.JoystickButton10 = 340
	
	Enum.KeyCode.JoystickButton11 = 341
	
	Enum.KeyCode.JoystickButton12 = 342
	
	Enum.KeyCode.JoystickButton13 = 343
	
	Enum.KeyCode.JoystickButton14 = 344
	
	Enum.KeyCode.JoystickButton15 = 345
	
	Enum.KeyCode.JoystickButton16 = 346
	
	Enum.KeyCode.JoystickButton17 = 347
	
	Enum.KeyCode.JoystickButton18 = 348
	
	Enum.KeyCode.JoystickButton19 = 349
	
	Enum.KeyCode.Joystick1Button0 = 350
	
	Enum.KeyCode.Joystick1Button1 = 351
	
	Enum.KeyCode.Joystick1Button2 = 352
	
	Enum.KeyCode.Joystick1Button3 = 353
	
	Enum.KeyCode.Joystick1Button4 = 354
	
	Enum.KeyCode.Joystick1Button5 = 355
	
	Enum.KeyCode.Joystick1Button6 = 356
	
	Enum.KeyCode.Joystick1Button7 = 357
	
	Enum.KeyCode.Joystick1Button8 = 358
	
	Enum.KeyCode.Joystick1Button9 = 359
	
	Enum.KeyCode.Joystick1Button10 = 360
	
	Enum.KeyCode.Joystick1Button11 = 361
	
	Enum.KeyCode.Joystick1Button12 = 362
	
	Enum.KeyCode.Joystick1Button13 = 363
	
	Enum.KeyCode.Joystick1Button14 = 364
	
	Enum.KeyCode.Joystick1Button15 = 365
	
	Enum.KeyCode.Joystick1Button16 = 366
	
	Enum.KeyCode.Joystick1Button17 = 367
	
	Enum.KeyCode.Joystick1Button18 = 368
	
	Enum.KeyCode.Joystick1Button19 = 369
	
	Enum.KeyCode.Joystick2Button0 = 370
	
	Enum.KeyCode.Joystick2Button1 = 371
	
	Enum.KeyCode.Joystick2Button2 = 372
	
	Enum.KeyCode.Joystick2Button3 = 373
	
	Enum.KeyCode.Joystick2Button4 = 374
	
	Enum.KeyCode.Joystick2Button5 = 375
	
	Enum.KeyCode.Joystick2Button6 = 376
	
	Enum.KeyCode.Joystick2Button7 = 377
	
	Enum.KeyCode.Joystick2Button8 = 378
	
	Enum.KeyCode.Joystick2Button9 = 379
	
	Enum.KeyCode.Joystick2Button10 = 380
	
	Enum.KeyCode.Joystick2Button11 = 381
	
	Enum.KeyCode.Joystick2Button12 = 382
	
	Enum.KeyCode.Joystick2Button13 = 383
	
	Enum.KeyCode.Joystick2Button14 = 384
	
	Enum.KeyCode.Joystick2Button15 = 385
	
	Enum.KeyCode.Joystick2Button16 = 386
	
	Enum.KeyCode.Joystick2Button17 = 387
	
	Enum.KeyCode.Joystick2Button18 = 388
	
	Enum.KeyCode.Joystick2Button19 = 389
	
	Enum.KeyCode.Joystick3Button0 = 390
	
	Enum.KeyCode.Joystick3Button1 = 391
	
	Enum.KeyCode.Joystick3Button2 = 392
	
	Enum.KeyCode.Joystick3Button3 = 393
	
	Enum.KeyCode.Joystick3Button4 = 394
	
	Enum.KeyCode.Joystick3Button5 = 395
	
	Enum.KeyCode.Joystick3Button6 = 396
	
	Enum.KeyCode.Joystick3Button7 = 397
	
	Enum.KeyCode.Joystick3Button8 = 398
	
	Enum.KeyCode.Joystick3Button9 = 399
	
	Enum.KeyCode.Joystick3Button10 = 400
	
	Enum.KeyCode.Joystick3Button11 = 401
	
	Enum.KeyCode.Joystick3Button12 = 402
	
	Enum.KeyCode.Joystick3Button13 = 403
	
	Enum.KeyCode.Joystick3Button14 = 404
	
	Enum.KeyCode.Joystick3Button15 = 405
	
	Enum.KeyCode.Joystick3Button16 = 406
	
	Enum.KeyCode.Joystick3Button17 = 407
	
	Enum.KeyCode.Joystick3Button18 = 408
	
	Enum.KeyCode.Joystick3Button19 = 409
	
	Enum.KeyCode.Joystick4Button0 = 410
	
	Enum.KeyCode.Joystick4Button1 = 411
	
	Enum.KeyCode.Joystick4Button2 = 412
	
	Enum.KeyCode.Joystick4Button3 = 413
	
	Enum.KeyCode.Joystick4Button4 = 414
	
	Enum.KeyCode.Joystick4Button5 = 415
	
	Enum.KeyCode.Joystick4Button6 = 416
	
	Enum.KeyCode.Joystick4Button7 = 417
	
	Enum.KeyCode.Joystick4Button8 = 418
	
	Enum.KeyCode.Joystick4Button9 = 419
	
	Enum.KeyCode.Joystick4Button10 = 420
	
	Enum.KeyCode.Joystick4Button11 = 421
	
	Enum.KeyCode.Joystick4Button12 = 422
	
	Enum.KeyCode.Joystick4Button13 = 423
	
	Enum.KeyCode.Joystick4Button14 = 424
	
	Enum.KeyCode.Joystick4Button15 = 425
	
	Enum.KeyCode.Joystick4Button16 = 426
	
	Enum.KeyCode.Joystick4Button17 = 427
	
	Enum.KeyCode.Joystick4Button18 = 428
	
	Enum.KeyCode.Joystick4Button19 = 429
	
	Enum.KeyCode.Joystick5Button0 = 430
	
	Enum.KeyCode.Joystick5Button1 = 431
	
	Enum.KeyCode.Joystick5Button2 = 432
	
	Enum.KeyCode.Joystick5Button3 = 433
	
	Enum.KeyCode.Joystick5Button4 = 434
	
	Enum.KeyCode.Joystick5Button5 = 435
	
	Enum.KeyCode.Joystick5Button6 = 436
	
	Enum.KeyCode.Joystick5Button7 = 437
	
	Enum.KeyCode.Joystick5Button8 = 438
	
	Enum.KeyCode.Joystick5Button9 = 439
	
	Enum.KeyCode.Joystick5Button10 = 440
	
	Enum.KeyCode.Joystick5Button11 = 441
	
	Enum.KeyCode.Joystick5Button12 = 442
	
	Enum.KeyCode.Joystick5Button13 = 443
	
	Enum.KeyCode.Joystick5Button14 = 444
	
	Enum.KeyCode.Joystick5Button15 = 445
	
	Enum.KeyCode.Joystick5Button16 = 446
	
	Enum.KeyCode.Joystick5Button17 = 447
	
	Enum.KeyCode.Joystick5Button18 = 448
	
	Enum.KeyCode.Joystick5Button19 = 449
	
	Enum.KeyCode.Joystick6Button0 = 450
	
	Enum.KeyCode.Joystick6Button1 = 451
	
	Enum.KeyCode.Joystick6Button2 = 452
	
	Enum.KeyCode.Joystick6Button3 = 453
	
	Enum.KeyCode.Joystick6Button4 = 454
	
	Enum.KeyCode.Joystick6Button5 = 455
	
	Enum.KeyCode.Joystick6Button6 = 456
	
	Enum.KeyCode.Joystick6Button7 = 457
	
	Enum.KeyCode.Joystick6Button8 = 458
	
	Enum.KeyCode.Joystick6Button9 = 459
	
	Enum.KeyCode.Joystick6Button10 = 460
	
	Enum.KeyCode.Joystick6Button11 = 461
	
	Enum.KeyCode.Joystick6Button12 = 462
	
	Enum.KeyCode.Joystick6Button13 = 463
	
	Enum.KeyCode.Joystick6Button14 = 464
	
	Enum.KeyCode.Joystick6Button15 = 465
	
	Enum.KeyCode.Joystick6Button16 = 466
	
	Enum.KeyCode.Joystick6Button17 = 467
	
	Enum.KeyCode.Joystick6Button18 = 468
	
	Enum.KeyCode.Joystick6Button19 = 469
	
	Enum.KeyCode.Joystick7Button0 = 470
	
	Enum.KeyCode.Joystick7Button1 = 471
	
	Enum.KeyCode.Joystick7Button2 = 472
	
	Enum.KeyCode.Joystick7Button3 = 473
	
	Enum.KeyCode.Joystick7Button4 = 474
	
	Enum.KeyCode.Joystick7Button5 = 475
	
	Enum.KeyCode.Joystick7Button6 = 476
	
	Enum.KeyCode.Joystick7Button7 = 477
	
	Enum.KeyCode.Joystick7Button8 = 478
	
	Enum.KeyCode.Joystick7Button9 = 479
	
	Enum.KeyCode.Joystick7Button10 = 480
	
	Enum.KeyCode.Joystick7Button11 = 481
	
	Enum.KeyCode.Joystick7Button12 = 482
	
	Enum.KeyCode.Joystick7Button13 = 483
	
	Enum.KeyCode.Joystick7Button14 = 484
	
	Enum.KeyCode.Joystick7Button15 = 485
	
	Enum.KeyCode.Joystick7Button16 = 486
	
	Enum.KeyCode.Joystick7Button17 = 487
	
	Enum.KeyCode.Joystick7Button18 = 488
	
	Enum.KeyCode.Joystick7Button19 = 489
	
	Enum.KeyCode.Joystick8Button0 = 490
	
	Enum.KeyCode.Joystick8Button1 = 491
	
	Enum.KeyCode.Joystick8Button2 = 492
	
	Enum.KeyCode.Joystick8Button3 = 493
	
	Enum.KeyCode.Joystick8Button4 = 494
	
	Enum.KeyCode.Joystick8Button5 = 495
	
	Enum.KeyCode.Joystick8Button6 = 496
	
	Enum.KeyCode.Joystick8Button7 = 497
	
	Enum.KeyCode.Joystick8Button8 = 498
	
	Enum.KeyCode.Joystick8Button9 = 499
	
	Enum.KeyCode.Joystick8Button10 = 500
	
	Enum.KeyCode.Joystick8Button11 = 501
	
	Enum.KeyCode.Joystick8Button12 = 502
	
	Enum.KeyCode.Joystick8Button13 = 503
	
	Enum.KeyCode.Joystick8Button14 = 504
	
	Enum.KeyCode.Joystick8Button15 = 505
	
	Enum.KeyCode.Joystick8Button16 = 506
	
	Enum.KeyCode.Joystick8Button17 = 507
	
	Enum.KeyCode.Joystick8Button18 = 508
	
	Enum.KeyCode.Joystick8Button19 = 509



-- UnityEngine Space  Enum

	Enum.Space = {}
	
	Enum.Space.World = 0
	
	Enum.Space.Self = 1



-- UnityEngine AnimationBlendMode  Enum

	Enum.AnimationBlendMode = {}
	
	Enum.AnimationBlendMode.Blend = 0
	
	Enum.AnimationBlendMode.Additive = 1



-- UnityEngine QueueMode  Enum

	Enum.QueueMode = {}
	
	Enum.QueueMode.CompleteOthers = 0
	
	Enum.QueueMode.PlayNow = 2



-- UnityEngine PlayMode  Enum

	Enum.PlayMode = {}
	
	Enum.PlayMode.StopSameLayer = 0
	
	Enum.PlayMode.StopAll = 4



-- UnityEngine WrapMode  Enum

	Enum.WrapMode = {}
	
	Enum.WrapMode.Once = 1
	
	Enum.WrapMode.Loop = 2
	
	Enum.WrapMode.PingPong = 4
	
	Enum.WrapMode.Default = 0
	
	Enum.WrapMode.ClampForever = 8
	
	Enum.WrapMode.Clamp = 1	



-- UnityEngine TextAnchor  Enum

	Enum.TextAnchor = {}
	
	Enum.TextAnchor.UpperLeft = 0
	
	Enum.TextAnchor.UpperCenter = 1
	
	Enum.TextAnchor.UpperRight = 2
	
	Enum.TextAnchor.MiddleLeft = 3
	
	Enum.TextAnchor.MiddleCenter = 4
	
	Enum.TextAnchor.MiddleRight = 5
	
	Enum.TextAnchor.LowerLeft = 6
	
	Enum.TextAnchor.LowerCenter = 7
	
	Enum.TextAnchor.LowerRight = 8



-- UnityEngine CameraClearFlags  Enum

	Enum.CameraClearFlags = {}
	
	Enum.CameraClearFlags.Skybox = 1
	
	Enum.CameraClearFlags.Color = 2
	
	Enum.CameraClearFlags.SolidColor = 2
	
	Enum.CameraClearFlags.Depth = 3
	
	Enum.CameraClearFlags.Nothing = 4



-- UnityEngine BlendWeights  Enum

	Enum.BlendWeights = {}
	
	Enum.BlendWeights.OneBone = 1
	
	Enum.BlendWeights.TwoBones = 2
	
	Enum.BlendWeights.FourBones = 4	



-- UnityEngine.UI.Image FillMethod  Enum

	Enum.FillMethod = {}
	
	Enum.FillMethod.Horizontal = 0
	
	Enum.FillMethod.Vertical = 1
	
	Enum.FillMethod.Radial90 = 2
	
	Enum.FillMethod.Radial180 = 3
	
	Enum.FillMethod.Radial360 = 4	



-- System.IO SearchOption  Enum

	Enum.SearchOption = {}
	
	Enum.SearchOption.TopDirectoryOnly = 0
	
	Enum.SearchOption.AllDirectories = 1	



-- UnityEngine ScreenOrientation  Enum

	Enum.ScreenOrientation = {}

	Enum.ScreenOrientation.Portrait = 0

	Enum.ScreenOrientation.PortraitUpsideDown = 1

	Enum.ScreenOrientation.LandscapeLeft = 2

	Enum.ScreenOrientation.LandscapeRight = 3

	Enum.ScreenOrientation.AutoRotation = 4


