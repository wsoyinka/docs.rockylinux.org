import * as React from "react";

export default () => {
    return (
        <>
            <div className="h-14 bg-gray-900 px-4 flex items-center text-white sm:hidden">
                <div className="menuIcon w-6 h-6 mr-3">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 8h16M4 16h16" />
                    </svg>
                </div>
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M23.3322 15.9572C23.7648 14.7182 24 13.3866 24 12C24 5.37258 18.6274 0 12 0C5.37258 0 0 5.37258 0 12C0 15.2793 1.31537 18.2513 3.44728 20.4173L15.6198 8.2448L23.3322 15.9572Z" fill="#10B981"/>
                    <path d="M21.1403 19.7757L15.6198 14.2552L6.97472 22.9003C8.50336 23.6062 10.2057 24 12 24C15.6611 24 18.9392 22.3605 21.1403 19.7757Z" fill="#10B981"/>
                </svg>
                <div className="w-4 h-4 mx-2">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                    </svg>
                </div>
                <span class="font-bold font-display">Documentation</span>
            </div>
            <div className="h-14 bg-gray-900 px-4 flex justify-center items-center text-white hidden sm:flex">
                <div id="inner" className="max-w-screen-lg w-full flex items-center">
                    <div className="flex items-center">
                        <div className="flex items-center mr-8">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                <path d="M23.3322 15.9572C23.7648 14.7182 24 13.3866 24 12C24 5.37258 18.6274 0 12 0C5.37258 0 0 5.37258 0 12C0 15.2793 1.31537 18.2513 3.44728 20.4173L15.6198 8.2448L23.3322 15.9572Z" fill="#10B981"/>
                                <path d="M21.1403 19.7757L15.6198 14.2552L6.97472 22.9003C8.50336 23.6062 10.2057 24 12 24C15.6611 24 18.9392 22.3605 21.1403 19.7757Z" fill="#10B981"/>
                            </svg>
                            <div className="w-4 h-4 mx-2">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                                </svg>
                            </div>
                            <span class="font-bold font-display">Documentation</span>
                        </div>
                        <div class="flex items-center">
                            <a class="text-sm mr-4 font-bold" href="/">Home</a>
                            <a class="text-sm mr-4" href="/">Manuals</a>
                            <a class="text-sm mr-4" href="/">Guides</a>
                            <a class="text-sm mr-4" href="/">Contributing</a>
                        </div>
                    </div>
                </div>
            </div>
        </>
    );
};