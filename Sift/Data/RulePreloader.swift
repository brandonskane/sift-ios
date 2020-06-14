//
//  RulePreloader.swift
//  Sift
//
//  Created by Brandon Kane on 6/10/20.
//  Copyright © 2020 Brandon Kane. All rights reserved.
//

import Foundation
import RealmSwift

class RulePreloader {
    let adHosts: [String] = [
    "aax-us-east.amazon-adsystem.com",
    "my-azurestage.rapidadvance.info",
    "gcs-us-00002.content-storage-download.googleapis.com",
    "um2.eqads.com",
    "static.adsafeprotected.com",
    "pixel.adsafeprotected.com",
    "ad.turn.com",
    "c.amazon-adsystem.com",
    "sdk.iad-06.braze.com",
    "q017o-ycbgf.ads.tremorhub.com",
    "p.adsymptotic.com",
    "secure.adnxs.com",
    "reading-list.api.nytimes.com",
    "a.teads.tv",
    "match.adsby.bidtheatre.com",
    "ads.adaptv.advertising.com",
    "metadata.provider.plex.tv",
    "aax.amazon-adsystem.com",
    "q017o-hspcn.ads.tremorhub.com",
    "heads-fa.scdn.co",
    "loadus.exelator.com",
    "i2-xhqwpawpdxwgwvnxactqifybqctsqg.init.cedexis-radar.net",
    "assets.evolutionadv.it",
    "pubads.g.doubleclick.net",
    "mobile2.adp.com",
    "ads.pubmatic.com",
    "i2-pvnolurcbtelhzgrnptgdlionneeji.init.cedexis-radar.net",
    "ads.creative-serving.com",
    "delivery-cdn-cf.adswizz.com",
    "mobile.adp.com",
    "adsassets.waze.com",
    "adserver-us.adtech.advertising.com",
    "i2-xlwqboclmomjotufnyjzpwblcetpmy.init.cedexis-radar.net",
    "d.adroll.com",
    "static.ads-twitter.com",
    "googleads.g.doubleclick.net",
    "ocsp.godaddy.com",
    "aax-eu.amazon-adsystem.com",
    "pixel.advertising.com",
    "ads.yahoo.com",
    "i2-jgxrzkkmsbegecigouuiigheftikay.init.cedexis-radar.net",
    "app.adjust.com",
    "s3-iad-ww.cf.videorolls.row.aiv-cdn.net",
    "mads.amazon.com",
    "iadsdk.apple.com",
    "s.amazon-adsystem.com",
    "ads.netweek.it",
    "lamiacasadolcecasa.it",
    "js.hsleadflows.net",
    "nep.advangelists.com",
    "npr.deliveryengine.adswizz.com",
    "prg.smartadserver.com",
    "m.adnxs.com",
    "ad.mrtnsvr.com",
    "sp.auth.adobe.com",
    "c1.adform.net",
    "z.moatads.com",
    "acdn.adnxs.com",
    "s8t.teads.tv",
    "pool.admedo.com",
    "pagead2.googlesyndication.com",
    "px.ads.linkedin.com",
    "ads.rubiconproject.com",
    "pixel.tapad.com",
    "ads-resources.waze.com",
    "www.googleadservices.com",
    "i6.liadm.com",
    "advil.waze.com",
    "vvgp7fyxg7v5axxduuoa-pzi2v1-ad3f5c37c-clientnsv4-s.akamaihd.net",
    "securepubads.g.doubleclick.net",
    "match.adsrvr.org",
    "ib.adnxs.com",
    "assets.adobedtm.com",
    "adservice.google.com",
    "ad.doubleclick.net",
    "mads.amazon-adsystem.com",
    "cdn.adsafeprotected.com",
    "js.hsadspixel.net",
    "load77.exelator.com",
    "sync.teads.tv",
    "r.dlx.addthis.com",
    "radar.cedexis.com",
    "news.iadsdk.apple.com",
    "i.liadm.com",
    "rtb.adentifi.com",
    "t.teads.tv",
    "mobile-http-intake.logs.datadoghq.com",
    "cm.adgrx.com",
    "cf.iadsdk.apple.com",
    "rtb.mfadsrvr.com",
    "loadm.exelator.com",
    "p.liadm.com",
    "dsp.adfarm1.adition.com",
    "www.googletagservices.com"
    ]

    
    let trackerHosts: [String] = [
                                "view.adjust.com",
                                "app.adjust.com",
                                "graph.facebook.com",
                                "js.hsleadflows.net"]
    
    let analyticHosts: [String] = [
                                "mobile-http-intake.logs.datadoghq.com",
                                "www.googletagservices.com",
                                "profile.localytics.com",
                                "manifest.localytics.com"]
    
    func printRules() {
        let hosts = Database.shared.getAllHosts()
        print("[")
        for host in hosts {
            let hostname = host.hostname
            guard hostname.contains("ad") else { continue }
            print("\"\(host.hostname)\",")
        }
        print("]")
    }
    
    func loadAdRules() {
        for ad in adHosts {
            guard Database.shared.getHost(hostname: ad, ifExistsOnly: true) == nil else {
                print("rule already exists")
                continue
            }
            Database.shared.createHost(hostname: ad,
                                       isAllowed: false,
                                       category: .ad)
            print("creating new ad rule")
        }
    }
    
    func updateAdRules() {
        for ad in adHosts {
            let host = Database.shared.getHost(hostname: ad)
            try! Database.shared.realm.write {
                host!.isAllowed = false
            }
        }
    }
    
    func loadTrackerRules() {
        for tracker in trackerHosts {
            guard Database.shared.getHost(hostname: tracker, ifExistsOnly: true) == nil else {
                print("rule already exists")
                continue
            }
            Database.shared.createHost(hostname: tracker,
                                       isAllowed: false,
                                       category: .tracker)
        }
    }
    
    func loadAnalyticsRules() {
        for analytic in analyticHosts {
            guard Database.shared.getHost(hostname: analytic, ifExistsOnly: true) == nil else {
                print("rule already exists")
                continue
            }
            Database.shared.createHost(hostname: analytic,
                                       isAllowed: false,
                                       category: .analytics)
        }
    }
}
