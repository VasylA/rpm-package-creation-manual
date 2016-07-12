Name: greenpak-designer
Version: 5.08
Release: 1
Summary: GreenPAK1-5 Designer
Group: Applications/Engineering
License: EULA
Source0: %{name}-%{version}-%{release}.tar.gz
BuildRoot: %{_tmppath}/%{name}-root
Packager: Silego Technology <info@silego.com>
Url: http://www.silego.com
Vendor: Silego Technology


%description
GreenPAK Designer™ is a full featured integrated development environment 
(IDE) that allows you to specify exactly how you want the device to be
configured. This provides you a direct access to all GreenPAK device
features and complete control over the routing and configuration options. 

GreenPAK Designer has an integrated programming tool that allows you
to program configured design into your GreenPAK chip. Also with this
tool you can read an already programmed chip and export these data to
Designer. Designer will generate a project which has the same configuration
as chip.

%prep
%setup -q -n %{name}-%{version}-%{release}

%build

%install 
mkdir -p %{buildroot}/lib
mkdir -p %{buildroot}/usr
cp -r lib %{buildroot}/
cp -r usr %{buildroot}/

%files
%defattr(-,root,root)
%{_bindir}/*
%{_prefix}/local/%{name}/*
%{_datadir}/applications/GreenPAK*.desktop
%{_datadir}/doc/%{name}/*
%{_datadir}/doc-base/%{name}
%{_datadir}/icons/hicolor/512x512/apps/slg7.png
%{_datadir}/icons/hicolor/512x512/apps/greenpak*.png
%{_datadir}/icons/hicolor/512x512/mimetypes/application-gp*-extension.png
%{_datadir}/icons/hicolor/scalable/mimetypes/application-gp*-extension.svg
%{_datadir}/man/man1/GP*
%{_datadir}/mime/packages/greenpak.xml
/lib/udev/rules.d/40-00-silego-devices-access.rules
 
%clean
rm -rf %{buildroot}

%changelog
* Tue Jul 12 2016 Silego Technology <info@silego.com> 5.08-1
- Initial Packaging

%post 
/sbin/ldconfig
update-mime-database /usr/share/mime
gtk-update-icon-cache /usr/share/icons/hicolor/ -f

%postun -p /sbin/ldconfig

