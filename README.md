# A Google Fonts proxy as a Docker image for GDPR compliance

Recently, several GDPR Data Protection Authorities restricted the usage of Google Fonts in websites
receiving visits from European Union residents.

These new restrictions make it more illegal to use Google Fonts directly. This proxy is a plug-and-play
replacement for Google Fonts that can be hosted on a custom domain to proxy Google Fonts and thus comply
with GDPR (as no personal data will be transferred to Google Fonts).

This image only relies on nginx and its substitution module: it's extremely fast, privacy friendly and 
production ready.

> The latest version is based on https://github.com/trajano/google-fonts-proxy-docker.

## Usage

Once setup (for instance at Citipo we run an instance on https://fonts.citipo.com), all requests done to 
the configured URL will be forwarded to Google Fonts with the same exact URL path and CSS responses
will be altered on-the-fly to change fonts files reference to use your own domain. 

**This forwarding will be done fully anonymously so that the client IP and personal data won't ever 
be transmitted to Google.**

Once deployed, you can use the service by directly replacing the Google Fonts URL with your own:

```html
<link href="https://fonts.googleapis.com/css2?family=Assistant:ital,wght@0,400;0,700;0,800;1,400;1,700" rel="stylesheet" crossorigin="anonymous" />
<!-- becomes -->
<link href="https://fonts.citipo.com/css2?family=Assistant:ital,wght@0,400;0,700;0,800;1,400;1,700" rel="stylesheet" crossorigin="anonymous" />
```

## Setup

With docker-compose:

```yaml
services:
    fonts:
        image: ghcr.io/citipo/docker-google-fonts-proxy
        ports:
            # You can use a proxy (like https://github.com/nginx-proxy/nginx-proxy) 
            # to provide SSL
            - '80:80'
        environment:
            # The host you use for fonts: references to Google Fonts 
            # will be replaced to this host in CSS files
            FONTS_HOST: fonts.citipo.com
        volumes:
            # The fonts and CSS files will be cached locally in this directory for 30 days
            # in order to avoid sending too many requests to Google Fonts
            - './storage:/data/nuts'
```

With Docker CLI:

```bash
docker run -d \ 
    -p 80:80 \
    -e FONTS_HOST=fonts.citipo.com \
    ghcr.io/citipo/docker-google-fonts-proxy
```

## For developers: what to tell you Data Protection Officer?

Your Data Protection Officer (the person responsible for GDPR in your company) may be curious about the details
of this tool, especially given the amount of media coverage the latest Google Fonts GDPR issues had.

To answer their questions, you can explain that this tool *anonymizes data* (in the GDPR meaning): it transforms
personal, indirectly identifiable data into fully anonymous requests towards Google. As long as you host this
service in your own infrastructure, no personal data is ever transferred to Google (or any other intermediate).

Data anonymization (which is different from pseudonymization) ensures that the data transferred to Google isn't
covered by GDPR, thus not being a compliance issue. 
