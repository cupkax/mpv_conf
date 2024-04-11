-- Copyright (c) 2022-2024 dyphire <qimoge@gmail.com>
-- License: MIT
-- link: https://github.com/dyphire/mpv-scripts

--[[
The script calls up a window in mpv to quickly load the folder/files/url/iso/clipboard/other subtitles/other audio tracks/other video tracks.
Usage, add bindings to input.conf:
key        script-message-to open_dialog import_folder
key        script-message-to open_dialog import_url
key        script-message-to open_dialog import_files
key        script-message-to open_dialog import_files <type>  # vid, aid, sid (video/audio/subtitle track)
key        script-message-to open_dialog import_clipboard
key        script-message-to open_dialog import_clipboard <type>  # vid, aid, sid (video/audio/subtitle track)
]]--

local msg = require 'mp.msg'
local utils = require 'mp.utils'
local options = require 'mp.options'

o = {
    video_types = '3g2,3gp,asf,avi,f4v,flv,h264,h265,m2ts,m4v,mkv,mov,mp4,mp4v,mpeg,mpg,ogm,ogv,rm,rmvb,ts,vob,webm,wmv,y4m',
    audio_types = 'aac,ac3,aiff,ape,au,cue,dsf,dts,flac,m4a,mid,midi,mka,mp3,mp4a,oga,ogg,opus,spx,tak,tta,wav,weba,wma,wv',
    image_types = 'apng,avif,bmp,gif,j2k,jp2,jfif,jpeg,jpg,jxl,mj2,png,svg,tga,tif,tiff,webp',
    subtitle_types = 'aqt,ass,gsub,idx,jss,lrc,mks,pgs,pjs,psb,rt,sbv,slt,smi,sub,sup,srt,ssa,ssf,ttxt,txt,usf,vt,vtt',
    playlist_types = 'm3u,m3u8,pls,cue',
    iso_types = 'iso',
}
options.read_options(o)

local function split(input)
    local ret = {}
    for str in string.gmatch(input, "([^,]+)") do
        ret[#ret + 1] = string.format("*.%s", str)
    end
    return ret
end

-- pre-defined file types
local file_types = {
    video = table.concat(split(o.video_types), ';'),
    audio = table.concat(split(o.audio_types), ';'),
    image = table.concat(split(o.image_types), ';'),
    iso = table.concat(split(o.iso_types), ';'),
    subtitle = table.concat(split(o.subtitle_types), ';'),
    playlist = table.concat(split(o.playlist_types), ';'),
}

-- open bluray iso or dir
local function open_bluray(path)
    mp.set_property('bluray-device', path)
    mp.commandv('loadfile', 'bd://')
end

-- open dvd iso or dir
local function open_dvd(path)
    mp.set_property('dvd-device', path)
    mp.commandv('loadfile', 'dvd://')
end

-- open folder
local function open_folder(path)
    local fpath, dir = utils.split_path(path)
    if utils.file_info(utils.join_path(path, "BDMV")) then
        open_bluray(path)
    elseif utils.file_info(utils.join_path(path, "VIDEO_TS")) then
        open_dvd(path)
    elseif dir:upper() == "BDMV" then
        open_bluray(fpath)
    elseif dir:upper() == "VIDEO_TS" then
        open_dvd(fpath)
    else
        mp.commandv('loadfile', path)
    end
end

-- open files
local function open_files(path, type, i, is_clip)
    local ext = string.match(path, "%.([^%.]+)$"):lower()
    if file_types['subtitle']:match(ext) then
        mp.commandv('sub-add', path, 'cached')
    elseif type == 'vid' and (not is_clip or (file_types['video']:match(ext) or file_types['image']:match(ext))) then
        mp.commandv('video-add', path, 'cached')
    elseif type == 'aid' and (not is_clip or file_types['audio']:match(ext)) then
        mp.commandv('audio-add', path, 'cached')
    elseif file_types['iso']:match(ext) then
        open_bluray(path)
        mp.add_timeout(1.0, function()
            if loaded_fail then
                open_dvd(path)
            end
        end)
    else
        mp.commandv('loadfile', path, i == 1 and 'replace' or 'append')
    end
end

-- import folder
local function import_folder()
    local was_ontop = mp.get_property_native("ontop")
    if was_ontop then mp.set_property_native("ontop", false) end
    local powershell_script = [[
        $u8 = [System.Text.Encoding]::UTF8
        $out = [Console]::OpenStandardOutput()
        $AssemblyFullName = 'System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089'
        $Assembly = [System.Reflection.Assembly]::Load($AssemblyFullName)
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.AddExtension = $false
        $OpenFileDialog.CheckFileExists = $false
        $OpenFileDialog.DereferenceLinks = $true
        $OpenFileDialog.Filter = "Folders|`n"
        $OpenFileDialog.Multiselect = $false
        $OpenFileDialogType = $OpenFileDialog.GetType()
        $FileDialogInterfaceType = $Assembly.GetType('System.Windows.Forms.FileDialogNative+IFileDialog')
        $IFileDialog = $OpenFileDialogType.GetMethod('CreateVistaDialog',@('NonPublic','Public','Static','Instance')).Invoke($OpenFileDialog,$null)
        $null = $OpenFileDialogType.GetMethod('OnBeforeVistaDialog',@('NonPublic','Public','Static','Instance')).Invoke($OpenFileDialog,$IFileDialog)
        [uint32]$PickFoldersOption = $Assembly.GetType('System.Windows.Forms.FileDialogNative+FOS').GetField('FOS_PICKFOLDERS').GetValue($null)
        $FolderOptions = $OpenFileDialogType.GetMethod('get_Options',@('NonPublic','Public','Static','Instance')).Invoke($OpenFileDialog,$null) -bor $PickFoldersOption
        $null = $FileDialogInterfaceType.GetMethod('SetOptions',@('NonPublic','Public','Static','Instance')).Invoke($IFileDialog,$FolderOptions)
        $VistaDialogEvent = [System.Activator]::CreateInstance($AssemblyFullName,'System.Windows.Forms.FileDialog+VistaDialogEvents',$false,0,$null,$OpenFileDialog,$null,$null).Unwrap()
        [uint32]$AdviceCookie = 0
        $AdvisoryParameters = @($VistaDialogEvent,$AdviceCookie)
        $AdviseResult = $FileDialogInterfaceType.GetMethod('Advise',@('NonPublic','Public','Static','Instance')).Invoke($IFileDialog,$AdvisoryParameters)
        $AdviceCookie = $AdvisoryParameters[1]
        $Result = $FileDialogInterfaceType.GetMethod('Show',@('NonPublic','Public','Static','Instance')).Invoke($IFileDialog,[System.IntPtr]::Zero)
        $null = $FileDialogInterfaceType.GetMethod('Unadvise',@('NonPublic','Public','Static','Instance')).Invoke($IFileDialog,$AdviceCookie)
        If (($Result -eq 0) -or ($Result -eq [System.Windows.Forms.DialogResult]::OK)) {
            $u8filename = $u8.GetBytes("$($OpenFileDialog.FileName)`n")
            $out.Write($u8filename, 0, $u8filename.Length)
        }
    ]]

    local res = mp.command_native({
        name = 'subprocess',
        playback_only = false,
        capture_stdout = true,
        args = {'powershell', '-NoProfile', '-Command', powershell_script},
    })

    if was_ontop then mp.set_property_native("ontop", true) end
    if (res.status ~= 0) then
        mp.osd_message("Failed to open folder dialog.")
    elseif res.stdout and res.stdout ~= "" then
        local folder_path = res.stdout:match("(.-)\n?$") -- Trim any trailing newline
        open_folder(folder_path)
    end
end

-- import files
local function import_files(type)
    local filter = ''
    local was_ontop = mp.get_property_native("ontop")
    if was_ontop then mp.set_property_native("ontop", false) end

    if type == 'vid' then
        filter = string.format("Video Files|%s|Image Files|%s", file_types['video'], file_types['image'])
    elseif type == 'aid' then
        filter = string.format("Audio Files|%s", file_types['audio'])
    elseif type == 'sid' then
        filter = string.format("Subtitle Files|%s", file_types['subtitle'])
    else
        filter = string.format("All Files (*.*)|*.*|Video Files|%s|Audio Files|%s|Image Files|%s|ISO Files|%s|Subtitle Files|%s|Playlist Files|%s",
            file_types['video'], file_types['audio'], file_types['image'], file_types['iso'], file_types['subtitle'], file_types['playlist'])
    end

    local res = mp.command_native({
        name = 'subprocess',
        playback_only = false,
        capture_stdout = true,
        args = { 'powershell', '-NoProfile', '-Command', string.format([[& {
            Trap {
                Write-Error -ErrorRecord $_
                Exit 1
            }
            Add-Type -AssemblyName PresentationFramework
            $u8 = [System.Text.Encoding]::UTF8
            $out = [Console]::OpenStandardOutput()
            $ofd = New-Object -TypeName Microsoft.Win32.OpenFileDialog
            $ofd.Multiselect = $true
            $ofd.Filter = "%s"
            If ($ofd.ShowDialog() -eq $true) {
                ForEach ($filename in $ofd.FileNames) {
                    $u8filename = $u8.GetBytes("$filename`n")
                    $out.Write($u8filename, 0, $u8filename.Length)
                }
            }
        }]], filter) }
    })
    if was_ontop then mp.set_property_native("ontop", true) end
    if (res.status ~= 0) then return end
    local i = 0
    for path in string.gmatch(res.stdout, '[^\n]+') do
        i = i + 1
        open_files(path, type, i, false)
    end
end

-- open url
local function import_url()
    local was_ontop = mp.get_property_native("ontop")
    if was_ontop then mp.set_property_native("ontop", false) end
    local res = mp.command_native({
        name = 'subprocess',
        playback_only = false,
        capture_stdout = true,
        args = { 'powershell', '-NoProfile', '-Command', [[& {
            Trap {
                Write-Error -ErrorRecord $_
                Exit 1
            }
            Add-Type -AssemblyName Microsoft.VisualBasic
            $u8 = [System.Text.Encoding]::UTF8
            $out = [Console]::OpenStandardOutput()
            $urlname = [Microsoft.VisualBasic.Interaction]::InputBox("Address", "Open", "https://")
            $u8urlname = $u8.GetBytes("$urlname")
            $out.Write($u8urlname, 0, $u8urlname.Length)
        }]]    }
    })
    if was_ontop then mp.set_property_native("ontop", true) end
    if (res.status ~= 0) then return end
    mp.commandv('loadfile', res.stdout)
end

-- Returns a string of UTF-8 text from the clipboard
local function get_clipboard()
    local res = mp.command_native({
        name = 'subprocess',
        playback_only = false,
        capture_stdout = true,
        args = { 'powershell', '-NoProfile', '-Command', [[& {
            Trap {
                Write-Error -ErrorRecord $_
                Exit 1
            }
    
            $clip = ""
            if (Get-Command "Get-Clipboard" -errorAction SilentlyContinue) {
                $clip = Get-Clipboard -Raw -Format Text -TextFormatType UnicodeText
            } else {
                Add-Type -AssemblyName PresentationCore
                $clip = [Windows.Clipboard]::GetText()
            }
    
            $clip = $clip -Replace "`r",""
            $u8clip = [System.Text.Encoding]::UTF8.GetBytes($clip)
            [Console]::OpenStandardOutput().Write($u8clip, 0, $u8clip.Length)
        }]] }
    })
    if not res.error then
        return res.stdout
    end
    return ''
end

-- open for clipboard
local function import_clipboard(type)
    local clip = get_clipboard():gsub("^[\'\"]", ""):gsub("[\'\"]$", "")
    if clip ~= '' then
        if clip:find('^%a[%w.+-]-://') then
            mp.commandv('loadfile', clip)
        else
            local meta = utils.file_info(clip)
            if not meta then
                mp.osd_message('Clipboard is not a valid URL or file path')
                msg.warn('Clipboard is not a valid URL or file path')
            elseif meta.is_dir then
                open_folder(clip)
            elseif meta.is_file then
                open_files(clip, type, 1, true)
            else
                mp.osd_message('Clipboard is not a valid URL or file path')
                msg.warn('Clipboard is not a valid URL or file path')
            end
        end
    else
        mp.osd_message('Clipboard is empty')
        msg.warn('Clipboard is empty')
    end
end


local function end_file(event)
    mp.unregister_event(end_file)
    if event["reason"] == "eof" or event["reason"] == "stop" or event["reason"] == "error" then
        local bd_device = mp.get_property_native("bluray-device")
        local dvd_device = mp.get_property_native("dvd-device")
        if event["reason"] == "error" and bd_device and bd_device ~= "" then
            loaded_fail = true
        else
            loaded_fail = false
        end
        if bd_device then mp.set_property("bluray-device", "") end
        if dvd_device then mp.set_property("dvd-device", "") end
    end
end

mp.register_event("end-file", end_file)

mp.register_script_message('import_folder', import_folder)
mp.register_script_message('import_files', import_files)
mp.register_script_message('import_url', import_url)
mp.register_script_message('import_clipboard', import_clipboard)
