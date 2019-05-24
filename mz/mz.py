#!/usr/bin/env python3
########################################################
#                                                      #
#                mz python3 - v1.0.0                   #
#            Created: Diego Sarzi - 2019               #
#                   License: MIT                       #
#                                                      #
########################################################

import sys, os, requests, csv, threading, itertools, time, re
from bs4 import BeautifulSoup

url = "http://mazonos.com/packages/"
filecsv = "mz_base.csv"
found = False

def menu():
    print("""mz 1.0.0 (amd64)
Usage: mz [options] command

mz is a commandline package manager and provides commands
for searching and managing packages next to bananapkg.

 search  - Search in package name
 install - Install packages
 remove  - Remove packages
 show    - Show description package
 update  - Update list packages in repositore online. Need Internet
 upgrade - Automate upgrade system base and bugs 
""")

done = False
textAnimate = ""
def animate():
    for c in itertools.cycle(['|', '/', '-', '\\']):
        if done:
            break
        sys.stdout.write('\r' + textAnimate + c)
        sys.stdout.flush()
        time.sleep(0.1)
    sys.stdout.write('\r' + textAnimate + 'complete!   \n')

try:
    sys.argv[1]
except IndexError:
    menu()
    exit(0)
else:
    choose = str(sys.argv[1])

def search():
    try:
        sys.argv[2]
    except IndexError:
        menu()
        exit(0)
    else:
        global found
        package = str(sys.argv[2])
        ### OPEN CSV
        with open(filecsv, 'r') as csvfile:
            csv_reader = csv.reader(csvfile)

            for line in csv_reader:
                if package in line[1]:
                    print(line[1].replace(".mz", " "))
                    found = True

            if found == False:
                print("Package not found.")

def show():
    try:
        sys.argv[2]
    except IndexError:
        menu()
        exit(0)
    else:
        global found
        package = str(sys.argv[2])
        ### OPEN CSV
        with open(filecsv, 'r') as csvfile:
            csv_reader = csv.reader(csvfile)

            for line in csv_reader:
                if package in line[1]:
                    found = True
                    r = requests.get(url+line[0]+line[2])
                    text = r.text
                    pkgname = re.findall('pkgname.*', text)
                    version = re.findall('version.*', text)
                    maintainer = re.findall('maintainer.*', text)
                    desc = re.findall('desc.*', text)
                    for p in pkgname:
                        print(p)
                    for v in version:
                        print(v)
                    for m in maintainer:
                        print(m)
                    for d in desc:
                        print(d + "...\n")

            if found == False:
                print("Package not found.")

def install():
    print("installing...")

def remove():
    print("removing...")

def update():
    global textAnimate
    global done
    textAnimate = "Updating "

    t = threading.Thread(target=animate)
    t.start()

    ### UPDATE WEB
    r = requests.get(url)
    
    soup = BeautifulSoup(r.content, "html.parser")
    links = soup.find_all("a")
    
    os.system("rm " + filecsv)
    for link in links:
        if '/' in link.text:
            urls = url + link.text
            r = requests.get(urls)

            soups = BeautifulSoup(r.content, "html.parser")
            linkss = soups.find_all("a")
            
            folder = link.text
            mz = ""
            desc = ""
            sha256 = ""

            for l in linkss:
                if '.mz' in l.text:
                    if l.text.endswith(('.mz')):
                        mz = l.text
                   
                    if l.text.endswith(('.desc')):
                        desc = l.text
                    
                    if l.text.endswith(('.sha256')):
                        sha256 = l.text
                    
                    if mz != "" and desc != "" and sha256 != "":
                        with open(filecsv, 'a') as new_file:
                            csv_writer = csv.writer(new_file)
                            csv_writer.writerow([folder,mz,desc,sha256])
                            mz = ""
                            desc = ""
                            sha256 = ""
    done = True

def upgrade():
    print("upgrading...")

chooses = ["search","install","remove","show","update","upgrade"]

if choose in chooses:
    functions = locals()
    functions[choose]()
else:
    menu()
    print("Invalid \"" + choose + "\" operation")
