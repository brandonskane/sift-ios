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
                            "load77.exelator.com",
                            "pool.admedo.com",
                            "delivery-cdn-cf.adswizz.com",
                            "a.teads.tv",
                            "ad.doubleclick.net",
                            "d.adroll.com",
                            "ad.turn.com",
                            "acdn.adnxs.com",
                            "pixel.adsafeprotected.com",
                            "q017o-hspcn.ads.tremorhub.com",
                            "sdk.iad-06.braze.com",
                            "ocsp.godaddy.com",
                            "t.teads.tv",
                            "streams.adobeprimetime.com",
                            "heads-fa.scdn.co",
                            "i2-xlwqboclmomjotufnyjzpwblcetpmy.init.cedexis-radar.net",
                            "c.amazon-adsystem.com",
                            "assets.evolutionadv.it",
                            "s8t.teads.tv",
                            "aax-us-east.amazon-adsystem.com",
                            "pubads.g.doubleclick.net",
                            "z.moatads.com",
                            "c1.adform.net",
                            "ads.pubmatic.com",
                            "cm.adgrx.com",
                            "secure.adnxs.com",
                            "securepubads.g.doubleclick.net",
                            "dsp.adfarm1.adition.com",
                            "match.adsby.bidtheatre.com",
                            "cdn.adsafeprotected.com",
                            "i6.liadm.com",
                            "aax-eu.amazon-adsystem.com",
                            "mads.amazon.com",
                            "news.iadsdk.apple.com",
                            "i2-xhqwpawpdxwgwvnxactqifybqctsqg.init.cedexis-radar.net",
                            "sp.auth.adobe.com",
                            "radar.cedexis.com",
                            "ads.creative-serving.com",
                            "i2-jgxrzkkmsbegecigouuiigheftikay.init.cedexis-radar.net",
                            "s.amazon-adsystem.com",
                            "rtb.adentifi.com",
                            "googleads.g.doubleclick.net",
                            "static.ads-twitter.com",
                            "ad.mrtnsvr.com",
                            "match.adsrvr.org",
                            "i.liadm.com",
                            "mobile.adp.com",
                            "r.dlx.addthis.com",
                            "m.adnxs.com",
                            "mobile2.adp.com",
                            "ads.adaptv.advertising.com",
                            "reading-list.api.nytimes.com",
                            "static.adp.com",
                            "iadsdk.apple.com",
                            "nep.advangelists.com",
                            "s3-iad-ww.cf.videorolls.row.aiv-cdn.net",
                            "static.adsafeprotected.com",
                            "mads.amazon-adsystem.com",
                            "lamiacasadolcecasa.it",
                            "q017o-ycbgf.ads.tremorhub.com",
                            "gcs-us-00002.content-storage-download.googleapis.com",
                            "p.adsymptotic.com",
                            "loadm.exelator.com",
                            "mobile-http-intake.logs.datadoghq.com",
                            "sync.teads.tv",
                            "loadus.exelator.com",
                            "metadata.provider.plex.tv",
                            "pixel.advertising.com",
                            "p.liadm.com",
                            "ads.netweek.it",
                            "cf.iadsdk.apple.com",
                            "um2.eqads.com",
                            "ads.yahoo.com",
                            "pixel.tapad.com",
                            "rtb.mfadsrvr.com",
                            "pagead2.googlesyndication.com",
                            "npr.deliveryengine.adswizz.com",
                            "ib.adnxs.com",
                            "i2-pvnolurcbtelhzgrnptgdlionneeji.init.cedexis-radar.net"]
    
    let trackerHosts: [String] = [
                                "view.adjust.com",
                                "app.adjust.com",
                                "graph.facebook.com"]
    
    let analyticHosts: [String] = [
                                "mobile-http-intake.logs.datadoghq.com",
                                "www.googletagservices.com",
                                "profile.localytics.com",
                                "manifest.localytics.com"]
    
    func printRules() {
        let hosts = Database.shared.getAllHosts()
        for host in hosts {
            let hostname = host.hostname
            guard hostname.contains("ad") else { continue }
            print("\"\(host.hostname)\",")
        }
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
