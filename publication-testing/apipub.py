import requests
import socket
hn=socket.gethostname()
url = "https://esg-idx.demonet.local/esg-search/ws/harvest"
mycertpath = "/root/.globus/certificate-file"
catalog = "https://%s/thredds/catalog/esgcet/1/cordex.output.AFR-44.SMHI.CCCma-CanESM2.historical.r0i0p0.RCA4.v1.fx.orog.v20130927.xml"%(hn)
postdata = {"uri" : catalog,
            "metadataRepositoryType":"THREDDS" }

resp = requests.post(url, cert=(mycertpath, mycertpath), data=postdata, verify=False )
print resp.status_code
print resp.text
