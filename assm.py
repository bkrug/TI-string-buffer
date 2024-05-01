# Run this script with XAS99 to assemble all files
# See https://endlos99.github.io/xdt99/
#
# If you can't run powershell scripts research this command locally:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
import os, glob, shutil, re
from itertools import chain

#Functions
def get_work_file(filename):
    return WORK_FOLDER + filename

def get_unlinked_string(object_files):
    unlinked_files = []
    for object_file in object_files:
        unlinked_files.append(get_work_file(object_file + TEMP_SUFFIX))
    return ' '.join(unlinked_files)

def link_test_files(linked_file, object_files):
    unlinked_files_string = get_unlinked_string(object_files)
    link_command_1 = 'xas99.py -l {source} -o {output}'
    link_command_2 = link_command_1.format(source = unlinked_files_string, output = get_work_file(linked_file))
    os.system(link_command_2)

#
# MAIN
#

WORK_FOLDER = './Fiad/'
PUBLISH_FOLDER = './Publish/'
TEMP_SUFFIX = '.obj'

#Assemble Src and Tests
files1 = os.scandir('.//Src')
files2 = os.scandir('.//Tests')
files = chain(files1, files2)

os.makedirs(os.path.dirname(WORK_FOLDER), exist_ok=True)
os.makedirs(os.path.dirname(PUBLISH_FOLDER), exist_ok=True)

# Assemble the files
for file_obj in files:
    print('Assembling ' + file_obj.name)
    list_file = get_work_file(file_obj.name.replace('.asm', '.lst'))
    obj_file = get_work_file(file_obj.name.replace('.asm', TEMP_SUFFIX))
    assemble_command_1 = 'xas99.py -q -S -R {source} -L {list} -o {obj}'
    assemble_command_2 = assemble_command_1.format(source = file_obj.path, list = list_file, obj = obj_file)
    os.system(assemble_command_2)

#
publish_files = [
    'ARRAY',
    'MEMBUF',
    'VAR'
]

# Add version information to some files
comment = ': Memory Management - 1.4.0 - https://github.com/bkrug/TI-string-buffer     '  # This line is intentionally 76 char long
for publish_file in publish_files:
    fileContent = ''
    with open(WORK_FOLDER + publish_file + TEMP_SUFFIX, 'r') as file:
        fileContent = file.read().rstrip()
    lastLineNo = fileContent[len(fileContent) - 4:]
    newContent = fileContent[:len(fileContent) - 80] + comment + lastLineNo
    with open(WORK_FOLDER + publish_file + TEMP_SUFFIX, 'w') as file:
        file.write(newContent)

# Create Test Runners
print('Linking Unit Test Runners')
temp_files = [ 'TESTFRAM', 'ARRYTST', 'ARRAY', 'MEMBUF', 'VAR' ]
link_test_files('ARRYRUN.obj', temp_files)

temp_files = [ 'TESTFRAM', 'MEMTST', 'MEMBUF', 'VAR' ]
link_test_files('MEMRUN.obj', temp_files)

# Add some files to a Disk image
disk_image = PUBLISH_FOLDER + 'BufferAndArray.dsk'
print('Creating disk image' + disk_image)
os.system('xdm99.py -X sssd ' + disk_image)
for obj_file in publish_files:
    add_command_1 = 'xdm99.py {disk_image} -a {obj_file} -f DIS/FIX80'
    add_command_2 = add_command_1.format(disk_image = disk_image, obj_file = WORK_FOLDER + obj_file + TEMP_SUFFIX)
    os.system(add_command_2)

# Create a version of the object files that can be used by XDT99
print('Creating headerless object files')
for file_obj in publish_files:
    shutil.copy(WORK_FOLDER + file_obj + TEMP_SUFFIX, PUBLISH_FOLDER + file_obj + '.noheader.obj')
    shutil.move(WORK_FOLDER + file_obj + TEMP_SUFFIX, PUBLISH_FOLDER + file_obj + '.obj')

# Add TIFILES header to all object files
print('Adding TIFILES header')
for file_obj in publish_files:
    header_command_1 = 'xdm99.py -T {object_file} -f DIS/FIX80 -o {object_file}'
    header_command_2 = header_command_1.format(object_file = PUBLISH_FOLDER + file_obj + '.obj')
    os.system(header_command_2)

#Clean up
for file in glob.glob(WORK_FOLDER + '*.lst'):
    os.remove(file)
for file in glob.glob(WORK_FOLDER + '*' + TEMP_SUFFIX):
    if not file.endswith('ARRYRUN.obj') and not file.endswith('MEMRUN.obj'):
        os.remove(file)