{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}

--------------------------------------------------------------------------------
module Main (main) where

--------------------------------------------------------------------------------
import qualified Utils.Color as Color
import qualified Utils.Icon as Icon

--------------------------------------------------------------------------------
import           Xmobar
import           Path.Parse

--------------------------------------------------------------------------------
data Env = Env { envConfigHome :: Path Abs Dir }

--------------------------------------------------------------------------------
main :: IO ()
main = do
  env <- Env <$> parseDirPath "$XDG_CONFIG_HOME"
  xmobar $ config env

--------------------------------------------------------------------------------
config :: Env -> Config
config env = defaultConfig {
  -- appearance
    font = "xft:Source Code Pro:size=14,Symbola:size=16,FontAwesome:size=14"
  , border = NoBorder
  , borderColor = Color.background
  , bgColor = Color.background
  , fgColor = Color.textRegular
  , alpha = 255
  , position = TopSize C 100 32

  -- layout
  , sepChar =  "%"   -- delineator between plugin names and straight text
  , alignSep = "}{"  -- separator between left-right alignment
  , template = concat
    [ "%StdinReader%"
    , "}{"
    , Icon.static "\x2328" <> " %kbd%"
    , " "
    , Icon.static "\xf1eb" <> " %wlp3s0wi%"
    , " "
    , "%default:Master%"
    , " "
    , "%battery%"
    , " "
    , "%date%"
    , " "
    ]

  -- general behavior
  , lowerOnStart =     True    -- send to bottom of window stack on start
  , hideOnStart =      False   -- start with window unmapped (hidden)
  , allDesktops =      True    -- show on all desktops
  , overrideRedirect = True    -- set the Override Redirect flag (Xlib)
  , pickBroadest =     False   -- choose widest display (multi-monitor)
  , persistent =       True    -- enable/disable hiding (True = disabled)

  -- icons
  , iconRoot = toFilePath $ envConfigHome env </> [reldir|xmonad/icons|]

  -- plugins
  , commands =
    [ Run $ Battery [ "--template" , "<acstatus>"
                    , "--Low"      , "20"        -- units: %
                    , "--High"     , "80"        -- units: %
                    , "--low"      , Color.textAlert
                    , "--normal"   , Color.textWarning
                    , "--high"     , Color.textRegular
                    , "--" -- battery specific options
                    -- discharging status
                    , "-o", Icon.static "\xf242" <> " <left>% (<timeleft>)"
                    -- AC "on" status
                    , "-O", Icon.static "\xf0e7" <> " <left>% (<timeleft>)"
                    -- charged status
                    , "-i", Icon.static "\xf240"
                    ] 50

    , Run $ Date dateTemplate "date" 10

    , Run $ Volume "default" "Master" [ "--template", "<status> <volume>%"
                                      ,  "--"
                                      , "-o", Icon.static "\x1F507"
                                      , "-O", Icon.static "\x1F50A"
                                      , "-c", Color.textRegular
                                      , "-C", Color.textRegular
                                      ] 10

    , Run $ Kbd []

    , Run $ Wireless "wlp3s0" [ "--template", "<essid>"
                              ] 100

    , Run StdinReader
    ]
  }

dateTemplate :: String
dateTemplate
  = concat
  [ Icon.static "\xf073"
  , " %F (%a) "
  , Icon.static "\x23F2"
  , " %T"
  ]