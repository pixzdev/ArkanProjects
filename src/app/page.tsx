import Background from "@/components/landing/Background";
import Navbar from "@/components/landing/Navbar";
import Hero from "@/components/landing/Hero";
import Features from "@/components/landing/Features";
import InstallGuide from "@/components/landing/InstallGuide";
import CliSection from "@/components/landing/CliSection";
import HowItWorks from "@/components/landing/HowItWorks";
import TechStack from "@/components/landing/TechStack";
import Compatibility from "@/components/landing/Compatibility";
import Faq from "@/components/landing/Faq";
import About from "@/components/landing/About";
import Footer from "@/components/landing/Footer";
import Reveal from "@/components/landing/Reveal";

export default function Home() {
  return (
    <>
      <Background />
      <Reveal />
      <Navbar />
      <main id="konten">
        <Hero />
        <Features />
        <InstallGuide />
        <CliSection />
        <HowItWorks />
        <TechStack />
        <Compatibility />
        <Faq />
        <About />
      </main>
      <Footer />
    </>
  );
}
