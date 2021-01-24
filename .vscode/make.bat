set script_path=%1
set "script_path=%script_path:\=/%"
bash -c "time bash %script_path%"